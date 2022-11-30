using DelimitedFiles
include("../src/TsetlinMachine.jl")

# Parameters for the Tsetlin Machine
T = 15 
s = 3.9
number_of_clauses = 20
states = 100

# Parameters of the pattern recognition problem
number_of_features = 16
number_of_classes = 3

# Training configuration
epochs = 200

data=open(readdlm,"../datasets/BinaryIrisData.txt")
data=convert(Array{Int64,2},data)

for row in size(data)[1]
    data[row,17] = min(1,data[row,17])
end

X_training = data[:, 1:16]
y_training = data[:, 17]

X_test = data[:, 1:16]
y_test = data[:, 17]

tsetlin_machine = TsetlinMachine.TsetlinMachineBase(number_of_clauses, number_of_features, s, states, T)
#TsetlinMachine.fit!(tsetlin_machine, X_training, y_training; epochs=epochs)
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
        println(prediction, " - ", y[i])
    end

    println("Accuracy: ", (length(y)-errors)/length(y))
end

accuracy(tsetlin_machine, X_test, y_test)
TsetlinMachine.print(tsetlin_machine)