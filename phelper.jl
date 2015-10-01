# Helper functions for parallel external sort


"""
Get new chunck of sorted data.
"""
function parallel_get_new_chunk(input_file_name,
                                input_file_position,
                                size_of_sorted_chunk)
    input_file = open(input_file_name, "r")
    input_buffer_array = Array(Int32, 0)

    # input_file_position < 0 means that the file was read already.
    if input_file_position < 0
         return input_buffer_array, -1
    end

    seek(input_file, input_file_position)
    for j in 1:size_of_sorted_chunk
        if eof(input_file)
            break
        else
            push!(input_buffer_array, read(input_file, Int32))
        end
    end

    if eof(input_file)
        new_input_position = -1
    else
        new_input_position = position(input_file)
    end

    return input_buffer_array, new_input_position
end

"""
Check if no more data on remote machines.
"""
function remote_machines_are_empty(input_remote_files_position)
    for position in input_remote_files_position
        if position != -1
            return false
        end
    end
    return true
end
