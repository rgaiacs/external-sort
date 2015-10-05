# Implement parallel external sort for 4-byte integers
#
# For more information https://en.wikipedia.org/wiki/External_sorting

@everywhere include("es.jl")
@everywhere include("phelper.jl")

"""
External sort.
"""
function parallel_external_sort(number_of_machines,
                                max_memory,
                                input_filename="sample.bin",
                                output_filename="sorted-sample.bin")
    files_on_machines = Array(Array{UTF8String}, number_of_machines)
    for i in 1:number_of_machines
        files_on_machines[i] = Array(UTF8String, 0)
    end

    # 1. Get the number of integers because this allow to send more data
    #    over network at each call.
    number_of_integers = 0
    input_file = open(input_filename, "r")
    while ~ eof(input_file)
        number_of_integers += 1
        read(input_file, Int32)
    end
    close(input_file)

    # 2. Send data over network.
    input_file = open(input_filename, "r")
    while ~ eof(input_file)
        for machine in 1:number_of_machines
            temporary_vector = Array(Int32, 0)
            # The loop is needed because otherwise it can raise
            # "EOFError: read end of file"
            for i in 1:max_memory
                if eof(input_file)
                    break
                else
                    push!(temporary_vector, read(input_file, Int32))
                end
            end

            # Array without elements will raise
            # UndefRefError: access to undefined reference
            if length(temporary_vector) == 0
                break
            end

            push!(files_on_machines[machine],
                  string("machine-", machine, "-", length(files_on_machines[machine]) + 1 ,"-sample.bin"))
            remotecall_wait(machine,
                       write_chunck_to_file,
                       temporary_vector,
                       files_on_machines[machine][end],
                       true,
                       false)
        end
    end
    close(input_file)

    # 3. Sort files on remote machine
    #    using the single machine version.
    @sync for machine in 1:number_of_machines
        remotecall_wait(machine,
                        external_sort_phase2,
                        max_memory,
                        files_on_machines[machine],
                        string("machine-", machine, "-sorted-sample.bin"))
    end

    # 4. Merge files locally.
    output_file = open(output_filename, "w")
    size_of_sorted_chunk = floor(Integer, max_memory / (number_of_machines + 1))
    input_remote_files_position = zeros(Int32, number_of_machines)  # We use -1 when the file ended.
    input_buffer = Array(Array{Int32}, number_of_machines)

    for machine in 1:number_of_machines
        # If using shared array we can't change the data.
        shared_array, input_remote_files_position[machine] = remotecall_fetch(
                machine,
                parallel_get_new_chunk,
                string("machine-", machine, "-sorted-sample.bin"),
                input_remote_files_position[machine],
                size_of_sorted_chunk)
        input_buffer[machine] = copy(shared_array)
    end

    while ~ input_buffer_is_empty(input_buffer)
        selected_machine = get_first_non_empty_input_buffer(input_buffer)
        for machine in selected_machine + 1:number_of_machines
            if length(input_buffer[machine]) > 0 && input_buffer[machine][1] < input_buffer[selected_machine][1]
                selected_machine = machine
            end
        end
        write(output_file, shift!(input_buffer[selected_machine]))

        if length(input_buffer[selected_machine]) == 0
            shared_array, input_remote_files_position[selected_machine] = remotecall_fetch(
                    selected_machine,
                    parallel_get_new_chunk,
                    string("machine-", selected_machine, "-sorted-sample.bin"),
                    input_remote_files_position[selected_machine],
                    size_of_sorted_chunk)
            input_buffer[selected_machine] = copy(shared_array)
        end
    end
    close(output_file)

    return
end
