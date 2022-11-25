using TsetlinMachine
using Test

@testset "TsetlinMachine.jl" begin
    @test TsetlinMachine.greet_tsetlin_machine() == "Hello TsetlinMachine!"
    @test TsetlinMachine.greet_tsetlin_machine() != "Hello world!"
end

