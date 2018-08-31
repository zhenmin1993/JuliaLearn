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
    name::String
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
Consumers = []
for i in 1:num_of_consumer
    new_consumer = Consumer("Con$i", rand(1:0.1:10,1)[1], rand(1:0.1:20,1)[1])
    push!(Consumers, new_consumer)
    println(new_consumer.name)
end

ThisMarketOperator = MarketOperator("MO",Generators,Consumers)

sort!(Consumers, by = x -> x.VoLL, rev=true)
println([Consumers[i].VoLL for i in 1:num_of_consumer])

function sortbybid(operator::MarketOperator)
    allgenerators = operator.generators
    allconsumers = operator.consumers
    num_of_generator = length(generators)
    num_of_consumer = length(consumers)
    sorted_generators = [allgenerators[1]]
    sorted_consumers = [allconsumers[1]]
    sort!(allgenerators, by = x -> x.bid_price)
    sort!(allconsumers, by = x -> x.bid_price, rev=true)

end

function update!(gen::Generator)
end

function update!(con::Consumer)
end

function clear(operator::MarketOperator)


end
