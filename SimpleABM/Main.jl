import PyPlot

include("AgentDefine.jl")
include("MarketClearing.jl")
include("TradePlot.jl")

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
sort!(Generators, by = x -> x.marginal_cost)

ThisHoldingCompany = HoldingCompany("Firm1",Generators,Consumers)
#status, price = OptimizeBidding(ThisHoldingCompany)
#println("Profit maximizing clear price", price)



#println([Consumers[i].VoLL for i in 1:num_of_consumer])






println("clear price: ", clear(ThisMarketOperator), " €/MWh")
PlotTrade(ThisMarketOperator)

function update!(company::HoldingCompany, clear_price)
end

function update!(con::Consumer, clear_price)
end
