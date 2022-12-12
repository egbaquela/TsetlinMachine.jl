using DelimitedFiles
include("../src/TsetlinMachine.jl")

# Parameters for the Tsetlin Machine
T = 15 
s = 3.9
number_of_clauses = 20
states = 100

# Parameters of the pattern recognition problem
number_of_features = 12
number_of_classes = 2

# Training configuration
epochs = 200

training_data=open(readdlm,"../datasets/NoisyXORTrainingData.txt")
training_data=convert(Array{Int64,2},training_data)
test_data=open(readdlm,"../datasets/NoisyXORTestData.txt")
test_data=convert(Array{Int64,2},test_data)

X_training = training_data[:, 1:12]
y_training = training_data[:, 13]

X_test = test_data[:, 1:12]
y_test = test_data[:, 13]

tsetlin_machine = TsetlinMachine.TsetlinMachineBase(number_of_clauses, number_of_features, s, states, T)
#TsetlinMachine.fit!(tsetlin_machine, X_training, y_training; epochs=epochs)
println(tsetlin_machine)
TsetlinMachine.fit!(tsetlin_machine, X_test[1,:], y_test[1])#; epochs=epochs)
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