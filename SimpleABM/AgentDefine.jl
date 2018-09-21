import PyPlot




mutable struct Generator
    name::String
    g_min::Float64
    g_max::Float64
    #fixed_cost::Float64
    #variable_cost::Float64
    marginal_cost::Float64
    offer_price::Float64
    offer_amount::Float64
    profit::Float64
end


mutable struct HoldingCompany
    name::String
    generator_portfolio::Vector{Generator}
end


mutable struct Consumer
    name::String
    demand::Float64
    VoLL::Float64
end

mutable struct ConsumerGroup
    allconsumers::Vector{Consumer}
    total_consumption::Float64
end


mutable struct MarketOperator
    name::String
    generators::Vector{Generator}
    consumers::Vector{Consumer}
end

num_of_generator = 3
num_of_consumer = 10000

generator1 = Generator("Gen1",0,20,20,30,20,0) #name, g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_amount(MWh), profit(€)
generator2 = Generator("Gen2",0,35,30,50,30,0) #name, g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_amount(MWh), profit(€)
generator3 = Generator("Gen3",0,60,60,80,50,0) #name, g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_amount(MWh), profit(€)
Generators = [generator1,generator2,generator3]
Consumers = []
for i in 1:num_of_consumer
    new_consumer = Consumer("Con$i", rand(1:0.1:12,1)[1], rand(1:5:200,1)[1])
    push!(Consumers, new_consumer)
    #println(new_consumer.name)
end

ThisConsumerGroup = ConsumerGroup(Consumers,0.0)

function CalculateTotalConsumption(consumergroup::ConsumerGroup)
    for i in 1:length(consumergroup.allconsumers)
        consumergroup.total_consumption = consumergroup.total_consumption + ThisConsumerGroup.allconsumers[i].demand
    end
end

CalculateTotalConsumption(ThisConsumerGroup)
println(ThisConsumerGroup.total_consumption)

ThisMarketOperator = MarketOperator("MO",Generators,Consumers)
sort!(Consumers, by = x -> x.VoLL, rev=true)
#println([Consumers[i].VoLL for i in 1:num_of_consumer])

function sortbybid(operator::MarketOperator)
    allgenerators = deepcopy(operator.generators)
    allconsumers = deepcopy(operator.consumers)
    num_of_generator = length(allgenerators)
    num_of_consumer = length(allconsumers)
    sorted_generators = [allgenerators[1]]
    sorted_consumers = [allconsumers[1]]
    sort!(allgenerators, by = x -> x.offer_price)
    sort!(allconsumers, by = x -> x.VoLL, rev=true)
    return allgenerators,allconsumers
end

function update!(company::HoldingCompany, clear_price)
end

function update!(con::Consumer, clear_price)
end

function clear(operator::MarketOperator)
    allgenerators,allconsumers = sortbybid(operator)
    generator_num = 1
    clear_price = 0
    residual = 0
    for consumer_num in 1:length(allconsumers)
        residual = 0
        allgenerators[generator_num].offer_amount += -allconsumers[consumer_num].demand / 1000
        if allgenerators[generator_num].offer_amount <= 0
            residual = - allgenerators[generator_num].offer_amount
            generator_num += 1
            allgenerators[generator_num].offer_amount += -residual / 1000
        end
        if allconsumers[consumer_num].VoLL <= (allgenerators[generator_num].offer_price)
            if residual > 0
                clear_price = (allconsumers[consumer_num].VoLL + allgenerators[generator_num-1].offer_price)/2
            end

            if residual == 0
                clear_price = allgenerators[generator_num].offer_price
            end
            println("good")
            println(residual)

            #print(clear_price)
            return clear_price

        end
    end
end

import PyPlot

function PlotTrade(operator::MarketOperator)
    allgenerators,allconsumers = sortbybid(operator)
    offer_price_all = [allgenerators[1].offer_price]
    cumulative_offer_amount_all = [0.0]
    bid_price_all = [allconsumers[1].VoLL]
    cumulative_bid_amount_all = [0.0]
    for consumer_num in 1:length(allconsumers)
        push!(bid_price_all, allconsumers[consumer_num].VoLL)
        push!(cumulative_bid_amount_all, allconsumers[consumer_num].demand/1000 + cumulative_bid_amount_all[end,])
    end

    for generator_num in 1:length(allgenerators)
        push!(offer_price_all, allgenerators[generator_num].offer_price)
        push!(cumulative_offer_amount_all, allgenerators[generator_num].offer_amount + cumulative_offer_amount_all[end,])
    end

    PyPlot.step(cumulative_bid_amount_all, bid_price_all)
    PyPlot.step(cumulative_offer_amount_all, offer_price_all)
end


println("clear price: ", clear(ThisMarketOperator), " €/MWh")
PlotTrade(ThisMarketOperator)
