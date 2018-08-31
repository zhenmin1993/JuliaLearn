<<<<<<< HEAD
mutable struct Generator
    name::String
    #g_max::Float64
    #g_min::Float64
    fixed_cost::Float64
    variable_cost::Float64
    bid_price::Float64
    bid_amount::Float64
    profit::Float64
end

mutable struct Consumer
    vame::String
    demand::Float64
    VoLL::Float64
end

mutable struct MarketOperator
    name::String
    generators::Vector{Generator}
    consumers::Vector{Consumer}

end

num_of_generator = 3
num_of_consumer = 100

generator1 = Generator("Gen1",100,10,20,50,0)
generator2 = Generator("Gen2",50,15,20,80,0)
generator3 = Generator("Gen3",20,30,40,100,0)
Generators = [generator1,generator2,generator3]

function update!(gen::Generator)
end

function update!(con::Consumer)
end

function clear(operator::MarketOperator)


=======
abstract type Agent end
mutable struct Generator <:Agent
    Profit <: Number
    #FixedCost <: Number
    #VariableCost <:Number
    #Revenue <: Number
    #Dispatch <: Number
end

mutable struct Consumer <:Agent
    VoLL <: Number
    Demand <: Number
end

function Trade(GeneratorGroup::Array{Generator},ConsumerGroup::Array{Consumer})
>>>>>>> 3309b413bb6c88d924bd70c81c45a8d4abcbc4ab
end
