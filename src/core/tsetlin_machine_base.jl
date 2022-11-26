struct TsetlinMachineBase
    number_of_clauses::Int64
	number_of_features::Int64
	
	s::Float64
	number_of_states::Int64
	threshold::Int64

	tsetlin_automaton_state::Vector{Vector{Vector{Int64}}}
	
	clause_sign::Vector{Int64}

	clause_output::Vector{Int64}

	feedback_to_clauses::Vector{Int64}
end

function TsetlinMachineBase(
    number_of_clauses::Int64,
	number_of_features::Int64,
	s::Float64,
	number_of_states::Int64,
	threshold::Int64)

	# The state of each Tsetlin Automaton is stored here. The automata are randomly initialized to either 'number_of_states' or 'number_of_states' + 1.
    tsetlin_automaton_state::Vector{Vector{Vector{Int64}}} = Vector(undef, number_of_clauses)
    for i in 1:number_of_clauses
        clause_automaton::Vector{Vector{Int64}} = Vector(undef, number_of_features)
        for j in 1:number_of_features
            clause_automaton[j] = sample([number_of_states, number_of_states + 1] ,2, replace = true)
        end
        tsetlin_automaton_state[i] = clause_automaton
    end

    clause_sign = ones(Int64, number_of_clauses)
    for i in 2:2:number_of_clauses
        clause_sign[i] = -1
    end 
    clause_output = zeros(Int64, number_of_clauses)
    feedback_to_clauses = zeros(Int64, number_of_clauses)

    return TsetlinMachineBase(
        number_of_clauses,
	    number_of_features,
	    s,
	    number_of_states,
	    threshold,
        tsetlin_automaton_state,
        clause_sign,
        clause_output,
        feedback_to_clauses)
end