module TsetlinMachine

export greet_tsetlin_machine
export TsetlinMachineBase
export state_to_action
export calculate_clause_output!
export calculate_clause_output
export get_state
export sum_up_clause_votes
export predict
export fit!

include("externals.jl")
include("functions.jl")
include("core/tsetlin_machine_base.jl")

end
