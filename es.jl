# Implement external sort for 4-byte integers
#
# For more information https://en.wikipedia.org/wiki/External_sorting

"""
External sort.
"""
function external_sort(max_memory, file_name="sample.bin")
    # Phase 1
    #
    # 1. Read max_memory numbers of the data in main memory
    # 2. Sort the data in main memory by some conventional method.
    # 3. Write the sorted data to disk.
    # 4. Repeat 1-3 until end of file.
    input_file = open(file_name, "r")
    bins = Array(ASCIIString,0)
    number_of_bins = 0
    while ~ eof(input_file)
        temporary_vector = read(input_file, UInt32, max_memory)
        sort!(temporary_vector)

        number_of_bins += 1
        bin_name = string("bin-", number_of_bins)
        push!(bins, bin_name)
        output_file = open(bin_name, "w")
        write(output_file, temporary_vector)
        close(output_file)
    end
    close(input_file)
end
