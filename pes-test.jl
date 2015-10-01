# Test for parallel external sort
#
# Call this file using
#
#     $ julia -p 2 ./pes-test.jl

using Base.Test

include("pes.jl")
include("helper.jl")

@testset "Parallel External Sort Tests" begin

    ############################ File with 12 integers ############################

    create_file(12)

    # Basic test
    parallel_external_sort(2, 4)
    @test check_sort()

end
