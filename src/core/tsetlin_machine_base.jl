struct TsetlinMachineBase
    number_of_clauses::Int64
	number_of_features::Int64
	
	s::Float64
	number_of_states::Int64
	threshold::Int64

    tsetlin_automaton_states::Array{Int64,3}
	
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
    tsetlin_automaton_states = Array{Int64}(undef, number_of_clauses, number_of_features, 2)
    for i in 1:number_of_clauses
        for j in 1:number_of_features
            for k in 1:2
                tsetlin_automaton_states[i,j,k] = sample([number_of_states, number_of_states + 1] ,1, replace = true)[1]
            end
        end
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

function print(tm::TsetlinMachineBase; raw_print::Bool=false)
    if raw_print==false
        Base.println("TsetlinMachineBase")
        Base.println("  number_of_clauses: ", tm.number_of_clauses)
        Base.println("  number_of_features: ", tm.number_of_features)
        Base.println("  s: ", tm.s)
        Base.println("  number_of_states: ", tm.number_of_states)
        Base.println("  threshold: ", tm.threshold)
    else
        Base.println(tm)
    end
end

#############################################
#  Auxiliary functions                      #
#############################################

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
    calculate_clause_output(
        tm::TsetlinMachineBase, 
        X::Vector{Int64})

Calculate clause outputs.

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

julia> calculate_clause_output(aux_tm, [0,1,0])
[0, 0, 1, 0, 0, 0, 0, 0, 1, 0]
```
"""
function calculate_clause_output(
    tm::TsetlinMachineBase, 
    X::Vector{Int64})

    clause_output = copy(tm.clause_output)
    for i in 1:tm.number_of_clauses
        clause_output[i] = 1

        for j in tm.number_of_features
            action_include = state_to_action(tm, tm.tsetlin_automaton_states[i,j,1])
            action_include_negated = state_to_action(tm, tm.tsetlin_automaton_states[i,j,2])

            if (action_include == 1 && X[j] == 0) || (action_include_negated == 1 && X[j] == 1)
                clause_output[i] = 0
                break
            end
        end
    end
    return clause_output
end


"""
    calculate_clause_output!(
        tm::TsetlinMachineBase, 
        X::Vector{Int64})

Updates clause outputs.

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

    #TODO: check which implementation has better performance
    #=
    for i in 1:tm.number_of_clauses
        tm.clause_output[i] = 1

        for j in tm.number_of_features
            action_include = state_to_action(tm, tm.tsetlin_automaton_states[i,j,1])
            action_include_negated = state_to_action(tm, tm.tsetlin_automaton_states[i,j,2])

            if (action_include == 1 && X[j] == 0) || (action_include_negated == 1 && X[j] == 1)
                tm.clause_output[i] = 0
                break
            end
        end
    end
    =#
    clause_output = calculate_clause_output(tm, X)
    for i in 1:tm.number_of_clauses
        tm.clause_output[i] = clause_output[i]
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


"""
    sum_up_clause_votes(
        tm::TsetlinMachineBase,
        clause_output::Vector{Int64})

        Sum up the votes for each output decision (y=0 or y = 1).

# Examples
```julia-repl

```
"""
function sum_up_clause_votes(
    tm::TsetlinMachineBase,
    clause_output::Vector{Int64})

    output_sum = 0

    for i in 1:tm.number_of_clauses
        output_sum += clause_output[i]*tm.clause_sign[i]
    end

    if output_sum > tm.threshold
        output_sum = tm.threshold
    elseif output_sum < -tm.threshold
        output_sum = -tm.threshold
    end

    return output_sum
end

"""
    sum_up_clause_votes(
        tm::TsetlinMachineBase)

        Sum up the votes for each output decision (y=0 or y = 1).

# Examples
```julia-repl

```
"""
function sum_up_clause_votes(
    tm::TsetlinMachineBase)

    return sum_up_clause_votes(tm, copy(tm.clause_output))
end

#############################################
# Prediction functions                      #
#############################################

"""
    predict(
        tm::TsetlinMachineBase,
        X::Vector{Int64})

        Return predicted value.

# Examples
```julia-repl

```
"""
function predict(
    tm::TsetlinMachineBase,
    X::Vector{Int64})

    output_sum = 0
    clause_output = calculate_clause_output(tm, X)

    output_sum = sum_up_clause_votes(tm, clause_output)

    if output_sum >= 0
        output_sum = 1
    else
        output_sum = 0
    end

    return output_sum
end

#############################################
#  Training functions                       #
#############################################

"""
    fit!(
        tm::TsetlinMachineBase,
        X::Vector{Int64},
        y::Int64)

        The Tsetlin Machine can be trained incrementally, one training example at a time.
        Use this method directly for online and incremental training.
# Examples
```julia-repl

```
"""
function fit!(
    tm::TsetlinMachineBase,
    X::Vector{Int64},
    y::Int64)

    calculate_clause_output!(tm, X)
    output_sum = sum_up_clause_votes(tm)


	#####################################
	## Calculate Feedback to Clauses    #
	#####################################
	# Initialize feedback to clauses
	for i in 1:tm.number_of_clauses
		tm.feedback_to_clauses[i] = 0
    end

    if y == 1
        # Calculate feedback to clauses
        for i in 1:tm.number_of_clauses
            if rand() <= 1.0*(tm.threshold - output_sum)/(2*tm.threshold)
                if tm.clause_sign[i] >= 0
                    # Type I Feedback				
                    tm.feedback_to_clauses[i] = 1
                else
                    # Type II Feedback
                    tm.feedback_to_clauses[i] = -1
                end
            end
        end

    elseif y==0
        # Calculate feedback to clauses
        for i in 1:tm.number_of_clauses
            if rand() <= 1.0*(tm.threshold + output_sum)/(2*tm.threshold)
                if tm.clause_sign[i] >= 0
                    # Type II Feedback				
                    tm.feedback_to_clauses[i] = -1
                else
                    # Type I Feedback
                    tm.feedback_to_clauses[i] = 1
                end
            end
        end
    end


    for i in 1:tm.number_of_clauses
        if tm.feedback_to_clauses[i] > 0
            #######################################################
            ### Type I Feedback (Combats False Negative Output) ###
            #######################################################
            if tm.clause_output[i] == 0
                for j in 1:tm.number_of_features
                    if rand() <= 1.0/tm.s 						
                        if tm.tsetlin_automaton_states[i,j,1] > 1 
                            tm.tsetlin_automaton_states[i,j,1] -= 1
                        end
                    end                          
                    if rand() <= 1.0/tm.s						
                        if tm.tsetlin_automaton_states[i,j,2] > 1
                            tm.tsetlin_automaton_states[i,j,2] -= 1
                        end
                    end 
                end

            elseif tm.clause_output[i] == 1
                for j in 1:tm.number_of_features
                    if X[j] == 1
                        if rand() <= 1.0*(tm.s-1)/tm.s
                            if tm.tsetlin_automaton_states[i,j,1] < tm.number_of_states*2
                                tm.tsetlin_automaton_states[i,j,1] += 1
                            end
                        end

                        if rand() <= 1.0/tm.s
                            if tm.tsetlin_automaton_states[i,j,2] > 1
                                tm.tsetlin_automaton_states[i,j,2] -= 1
                            end
                        end

                    elseif X[j] == 0
                        if rand() <= 1.0*(tm.s-1)/tm.s
                            if tm.tsetlin_automaton_states[i,j,2] < tm.number_of_states*2
                                tm.tsetlin_automaton_states[i,j,2] += 1
                            end
                        end

                        if rand() <= 1.0/tm.s
                            if tm.tsetlin_automaton_states[i,j,1] > 1
                                tm.tsetlin_automaton_states[i,j,1] -= 1
                            end
                        end
                    end
                end
            end
        
        elseif tm.feedback_to_clauses[i] < 0
            ########################################################
            ### Type II Feedback (Combats False Positive Output) ###
            ########################################################
            if tm.clause_output[i] == 1
                for j in 1:tm.number_of_features
                    action_include = state_to_action(tm, tm.tsetlin_automaton_states[i,j,1])
                    action_include_negated = state_to_action(tm, tm.tsetlin_automaton_states[i,j,2])

                    if X[j] == 0
                        if (action_include == 0) && (tm.tsetlin_automaton_states[i,j,1] < tm.number_of_states*2)
                            tm.tsetlin_automaton_states[i,j,1] += 1
                        end
                    elseif X[j] == 1
                        if (action_include_negated == 0) && (tm.tsetlin_automaton_states[i,j,2] < tm.number_of_states*2)
                            tm.tsetlin_automaton_states[i,j,2] += 1
                        end
                    end
                end
            end
        end
    end


end

"""
    fit!(
        tm::TsetlinMachineBase,
        X::Array{Int64},
        y::Vector{Int64};
        number_of_examples::Int64=2,
        epochs::Int64=100))

        Batch (offline) training of Tsetlin Machine.
# Examples
```julia-repl

```
"""
function fit!(
    tm::TsetlinMachineBase,
    X::Array{Int64},
    y::Vector{Int64};
    batch_size::Int64=2,
    epochs::Int64=100)

    # Is assumes that size(X)[1] == length(y)

    number_of_examples = size(X)[1]
    training_indexes = Vector(1:number_of_examples)
    for ep in 1:epochs
        shuffle!(training_indexes)
        for i in training_indexes
            fit!(tm, X[i,:], y[i])
        end
    end
end