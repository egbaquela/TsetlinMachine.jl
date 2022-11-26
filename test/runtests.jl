using TsetlinMachine
using Test


@testset "TsetlinMachine.jl" begin
    @test TsetlinMachine.greet_tsetlin_machine() == "Hello TsetlinMachine!"
    @test TsetlinMachine.greet_tsetlin_machine() != "Hello world!"
end

@testset "tsetlin_machine_base.jl" begin
    number_of_clauses = 10
	number_of_features = 3
	s = 1.0
	number_of_states = 2
	threshold = 5

    aux_tm = TsetlinMachineBase(
        number_of_clauses ,
        number_of_features,
        s,
        number_of_states,
        threshold)

    @test aux_tm.number_of_clauses == number_of_clauses
    @test aux_tm.number_of_features == number_of_features
    @test aux_tm.s == s
    @test aux_tm.number_of_states == number_of_states
    @test aux_tm.threshold == threshold

    @test length(aux_tm.clause_sign) == number_of_clauses
    @test length(aux_tm.clause_output) == number_of_clauses
    @test length(aux_tm.feedback_to_clauses) == number_of_clauses
end
