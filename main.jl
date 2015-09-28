# Command line wrapper for external sort
#
# Generate a random file, sort it and print the result to screen.
#
# Usage: julia main.jl N M
#
# N is the number of random 4-byte integers to sort.
# M is the number of integers of in-memory capacity to do sorting.

include("es.jl")
include("helper.jl")

if length(ARGS) == 2
    N = parse(UInt32, ARGS[1])
    M = parse(UInt32, ARGS[2])
end

create_file(N)
external_sort(M)
read_file2screen("sorted-sample.bin")
