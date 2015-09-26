# Test for external sort

using Base.Test

include("es.jl")
include("helper.jl")

# Basic test
create_file(12)
external_sort(4)
@test check_sort()

# Test not enough memory
@test_throws ErrorException external_sort(1)

# Another basic test
external_sort(6)
@test check_sort()

# Test with no divisible number
external_sort(5)
@test check_sort()
