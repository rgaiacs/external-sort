# Test for external sort

using Base.Test

include("es.jl")
include("helper.jl")

# Test not enough memory
@test_throws ErrorException external_sort(1)

############################ File with 12 integers ############################

create_file(12)

# "Unlimited" memory test
external_sort(36)
@test check_sort()

# Basic test
external_sort(4)
@test check_sort()

# Another basic test
external_sort(6)
@test check_sort()

# Test with no divisible number
external_sort(5)
@test check_sort()
