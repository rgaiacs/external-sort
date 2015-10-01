# Helper functions for external sort

"""
Write N random 4-byte integers to file (in binary form).
"""
function create_file(n, file_name="sample.bin")
    srand(13)  # Remove in the future
    file = open(file_name, "w")
    for i in 1:n
        write(file, rand(Int32))
    end
    close(file)
end

"""
Read file and print it to screen.
"""
function read_file2screen(file_name="sample.bin", print_name=false)
    if print_name
        println(string("Begin of ", file_name, ":"))
    end

    file = open(file_name, "r")
    while ~ eof(file)
        println(read(file, Int32))
    end
    close(file)

    if print_name
        println(string("End of ", file_name, ":"))
    end
end

"""
Read file to array.
"""
function read_file2array(file_name="sample.bin")
    file = open(file_name, "r")
    array2return = Array(Int32, 0)
    while ~ eof(file)
        push!(array2return, read(file, Int32))
    end
    close(file)
    return array2return
end

"""
Check external sort.
"""
function check_sort(input_filename="sample.bin", sorted_filename="sorted-sample.bin")
    input = read_file2array(input_filename)
    sort!(input)

    sorted = read_file2array(sorted_filename)

    check_result = input == sorted

    if ~ check_result
        println(string("sorted input: ", input))
        println(string("sorted file:  ", sorted))
    end

    return check_result
end
