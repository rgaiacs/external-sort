# Implement external sort for 4-byte integers
#
# For more information https://en.wikipedia.org/wiki/External_sorting

"""
External sort.
"""
function external_sort(max_memory,
                       input_filename="sample.bin",
                       output_filename="sorted-sample.bin")
    # Phase 1
    #
    # 1. Read max_memory numbers of the data in main memory
    # 2. Sort the data in main memory by some conventional method.
    # 3. Write the sorted data to disk.
    # 4. Repeat 1-3 until end of file.
    input_file = open(input_filename, "r")
    bin_names = Array(ASCIIString,0)
    number_of_bins = 0
    while ~ eof(input_file)
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
        sort!(temporary_vector)

        number_of_bins += 1
        bin_name = string("bin-", number_of_bins, ".bin")
        push!(bin_names, bin_name)
        output_file = open(bin_name, "w")
        write(output_file, temporary_vector)
        close(output_file)
    end
    close(input_file)

    # if number_of_bins is 1 we already have the solution
    if number_of_bins == 1
        mv(bin_names[1], output_filename, remove_destination=true)
        return
    end

    external_sort_phase2(max_memory,
                        [string("bin-", i, ".bin") for i in 1:number_of_bins],
                        output_filename)
end

function external_sort_phase2(max_memory,
                              input_filename_list,
                              output_filename="sorted-sample.bin")
    # Phase 2
    #
    # 1. Read the first max_memory / (number_of_bins + 1) of each sorted chunk into
    #    input buffers in main memory and allocate the remaining memory for an
    #    output buffer.
    # 2. Perform a k-way merge and store the result in the output buffer.
    #    Whenever the output buffer fills, write it to the final sorted file and empty it.
    #    Whenever any of the 9 input buffers empties, fill it with the next
    #    sorted chunk until no more data from the chunk is available.
    number_of_bins = length(input_filename_list)

    size_of_sorted_chunk = floor(Integer, max_memory / (number_of_bins + 1))
    if size_of_sorted_chunk == 0
        error("Number of bins is too large. Need more memory.")
    end

    output_file = open(output_filename, "w")

    # Open all bins
    bin_files = Array(IOStream, number_of_bins)
    for i in 1:number_of_bins
        bin_files[i] = open(input_filename_list[i], "r")
    end

    # Read first chunk
    input_buffer = Array(Array{Int32}, number_of_bins)
    for i in 1:number_of_bins
        input_buffer[i] = Array(Int32, 0)
        get_new_chunk(input_buffer[i], bin_files[i], size_of_sorted_chunk)
    end

    while ~ input_buffer_is_empty(input_buffer)
        selected_bin = get_first_non_empty_input_buffer(input_buffer)
        for i in selected_bin + 1:number_of_bins
            if length(input_buffer[i]) > 0 && input_buffer[i][1] < input_buffer[selected_bin][1]
                selected_bin = i
            end
        end
        write(output_file, shift!(input_buffer[selected_bin]))

        if length(input_buffer[selected_bin]) == 0
            get_new_chunk(input_buffer[selected_bin], bin_files[selected_bin], size_of_sorted_chunk)
        end
    end
    close(output_file)

    return
end

"""
Write chunck of data to file.
"""
function write_chunck_to_file(chunck,
                              output_filename,
                              sort=false,
                              append=true)
    if sort
        sort!(chunck)
    end

    if append
        mode = "a"
    else
        mode = "w"
    end
    output_file = open(output_filename, mode)
    write(output_file, chunck)
    close(output_file)
end

"""
Get new chunck of sorted data.
"""
function get_new_chunk(input_buffer_array,
                       input_file_stream,
                       size_of_sorted_chunk)
    for j in 1:size_of_sorted_chunk
        if eof(input_file_stream)
            close(input_file_stream)
        else
            push!(input_buffer_array, read(input_file_stream, Int32))
        end
    end
end

"""
Check if input buffer is empty.
"""
function input_buffer_is_empty(input_buffer)
    for chunck in input_buffer
        if length(chunck) != 0
            return false
        end
    end
    return true
end

"""
Get first non empty buffer.
"""
function get_first_non_empty_input_buffer(input_buffer)
    for i in 1:length(input_buffer)
        if length(input_buffer[i]) != 0
            return i
        end
    end
    return 0
end
