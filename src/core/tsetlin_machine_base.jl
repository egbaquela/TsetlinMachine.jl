struct TsetlinMachineBase
    number_of_clauses::Int64
	number_of_features::Int64
	
	s::Float64
	number_of_states::Int64
	threshold::Int64

	tsetlin_automaton_states::Vector{Vector{Vector{Int64}}}
	
	clause_sign::Vector{Int64}

	clause_output::Vector{Int64}

	feedback_to_clauses::Vector{Int64}
end

"""
    TsetlinMachineBase(
        number_of_clauses::Int64,
        number_of_features::Int64,
        s::Float64,
        number_of_states::Int64,
        threshold::Int64)

Create a basic Tsetlin Machine. This should be the constructor used.

# Examples
```julia-repl
julia> number_of_clauses = 10;
julia> number_of_features = 3;
julia> s = 1.0;
julia> number_of_states = 2;
julia> threshold = 5;

julia> aux_tm = TsetlinMachineBase(
    number_of_clauses ,
    number_of_features,
    s,
    number_of_states,
    threshold)
TsetlinMachineBase(10, 3, 1.0, 2, 5, [[[2, 2], [2, 2], [3, 2]], [[2, 2], [2, 3], [3, 2]], [[2, 2], [3, 3], [3, 3]], [[3, 2], [3, 2], [3, 2]], [[2, 2], [2, 2], [2, 2]], [[3, 2], [2, 2], [3, 2]], [[3, 2], [2, 2], [3, 2]], [[3, 2], [2, 3], [2, 2]], [[3, 2], [3, 3], [3, 2]], [[2, 3], [2, 3], [2, 3]]], [1, -1, 1, -1, 1, -1, 1, -1, 1, -1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
```
"""
function TsetlinMachineBase(
    number_of_clauses::Int64,
	number_of_features::Int64,
	s::Float64,
	number_of_states::Int64,
	threshold::Int64)

	# The state of each Tsetlin Automaton is stored here. The automata are randomly initialized to either 'number_of_states' or 'number_of_states' + 1.
    tsetlin_automaton_states::Vector{Vector{Vector{Int64}}} = Vector(undef, number_of_clauses)
    for i in 1:number_of_clauses
        clause_automaton::Vector{Vector{Int64}} = Vector(undef, number_of_features)
        for j in 1:number_of_features
            clause_automaton[j] = sample([number_of_states, number_of_states + 1] ,2, replace = true)
        end
        tsetlin_automaton_states[i] = clause_automaton
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
        tsetlin_automaton_states,
        clause_sign,
        clause_output,
        feedback_to_clauses)
end

"""
    state_to_action(
        tm::TsetlinMachineBase, 
        state::Int64)

Translate state to action.

# Examples
```julia-repl
julia> number_of_clauses = 10;
julia> number_of_features = 3;
julia> s = 1.0;
julia> number_of_states = 2;
julia> threshold = 5;

julia> aux_tm = TsetlinMachineBase(
    number_of_clauses ,
    number_of_features,
    s,
    number_of_states,
    threshold);

julia> state_to_action(aux_tm, 1)
0
```
"""
function state_to_action(tm::TsetlinMachineBase, state::Int64)
    result = 0
	if state > tm.number_of_states
		result = 1
    end
    return result
end

"""
    calculate_clause_output!(
        tm::TsetlinMachineBase, 
        X::Vector{Int64})

Updates claus outputs.

# Examples
```julia-repl
julia> number_of_clauses = 10;
julia> number_of_features = 3;
julia> s = 1.0;
julia> number_of_states = 2;
julia> threshold = 5;

julia> aux_tm = TsetlinMachineBase(
    number_of_clauses ,
    number_of_features,
    s,
    number_of_states,
    threshold)
TsetlinMachineBase(10, 3, 1.0, 2, 5, [[[2, 2], [2, 2], [3, 2]], [[2, 2], [2, 3], [3, 2]], [[2, 2], [3, 3], [3, 3]], [[3, 2], [3, 2], [3, 2]], [[2, 2], [2, 2], [2, 2]], [[3, 2], [2, 2], [3, 2]], [[3, 2], [2, 2], [3, 2]], [[3, 2], [2, 3], [2, 2]], [[3, 2], [3, 3], [3, 2]], [[2, 3], [2, 3], [2, 3]]], [1, -1, 1, -1, 1, -1, 1, -1, 1, -1], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])

julia> calculate_clause_output!(aux_tm, [0,1,0])
julia> aux_tm
TsetlinMachineBase(10, 3, 1.0, 2, 5, [[[3, 3], [3, 3], [3, 2]], [[2, 2], [2, 2], [3, 2]], [[3, 3], [3, 3], [2, 2]], [[2, 2], [3, 3], [3, 2]], [[2, 3], [3, 2], [3, 3]], [[3, 2], [2, 3], [3, 3]], [[3, 3], [2, 3], [3, 3]], [[3, 3], [2, 2], [3, 2]], [[2, 3], [2, 3], [2, 3]], [[3, 3], [3, 2], [3, 3]]], [1, -1, 1, -1, 1, -1, 1, -1, 1, -1], [0, 0, 1, 0, 0, 0, 0, 0, 1, 0], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
```
"""
function calculate_clause_output!(
    tm::TsetlinMachineBase, 
    X::Vector{Int64})

    for i in 1:tm.number_of_clauses
        tm.clause_output[i] = 1

        for j in tm.number_of_features
            action_include = state_to_action(tm, tm.tsetlin_automaton_states[i][j][1])
            action_include_negated = state_to_action(tm, tm.tsetlin_automaton_states[i][j][2])

            if (action_include == 1 && X[j] == 0) || (action_include_negated == 1 && X[j] == 1)
                tm.clause_output[i] = 0
                break
            end
        end
    end
end

"""
    get_state(
        tm::TsetlinMachineBase, 
        clause::Int64,
        feature::Int64,
        automaton_type::Int64)

        Get the state of a specific automaton, indexed by clause, feature, and automaton type (include/include negated).

# Examples
```julia-repl

```
"""
function get_state(
    tm::TsetlinMachineBase,
    clause::Int64,
    feature::Int64,
    automaton_type::Int64)

    return tm.tsetlin_automaton_states[clause][feature][automaton_type]
end
