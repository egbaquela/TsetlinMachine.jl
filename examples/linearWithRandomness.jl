using DelimitedFiles
include("../src/TsetlinMachine.jl")

test_data=open(readdlm,"../datasets/LinearWithRandomnessData.txt")
test_data=convert(Array{Int64,2},test_data)

num_columns = size(test_data)[2]
X_test = test_data[:, 1:(num_columns-1)]
y_test = test_data[:,num_columns]


# Parameters for the Tsetlin Machine
T = 15 
s = 3.9
number_of_clauses = 20
states = 100

# Parameters of the pattern recognition problem
number_of_features = num_columns - 1
number_of_classes = 2

# Training configuration
epochs = 200


tsetlin_machine = TsetlinMachine.TsetlinMachineBase(number_of_clauses, number_of_features, s, states, T)
println(tsetlin_machine)
TsetlinMachine.fit!(tsetlin_machine, X_test, y_test; epochs=epochs)
println(tsetlin_machine)
function accuracy(tm::TsetlinMachine.TsetlinMachineBase, X::Array{Int64}, y::Vector{Int64})
    errors=0
    for i in 1:length(y)
        prediction = TsetlinMachine.predict(tm, X[i,:])
        if prediction != y[i]
            errors += 1
        end
        #println(prediction, " - ", y[i])
    end

    println("Accuracy: ", (length(y)-errors)/length(y))
end

accuracy(tsetlin_machine, X_test, y_test)
TsetlinMachine.print(tsetlin_machine)