# Helper functions for external sort

"""
Write N random 4-byte integers to file (in binary form).
"""
function create_file(n, file_name="sample.bin")
    srand(13)  # Remove in the future
    file = open(file_name, "w")
    for i in 1:n
        write(file, rand(UInt32))
    end
    close(file)
end

"""
Read file and print it to screen.
"""
function read_file2screen(file_name="sample.bin")
    file = open(file_name, "r")
    while ~ eof(file)
        number = read(file, UInt32)
        println(number)
    end
    close(file)
end

"""
Read file to array.
"""
function read_file2array(file_name="sample.bin")
    file = open(file_name, "r")
    array2return = Array(UInt32, 1)
    while ~ eof(file)
        push!(array2return, read(file, UInt32))
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

    return input == sorted
end
