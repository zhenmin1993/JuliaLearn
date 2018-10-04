import PyPlot

include("AgentDefine.jl")
include("MarketClearing.jl")
include("TradePlot.jl")
include("OfferOptimize.jl")

num_of_generator = 3
num_of_consumer = 10000


Consumers = []
init_consumer_history = ConsumerHistory([],[],[])
srand(1234)
for i in 1:num_of_consumer
    new_consumer = Consumer("Con$i", rand(1:0.1:12,1)[1], rand(1:5:200,1)[1], deepcopy(init_consumer_history))
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

init_generator_history = GeneratorHistory([],[],[],[],[],[],[],[])
#name, g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_quantity(MWh), profit(€), price decision,quantity decision, history
generator1 = Generator("Gen1",10,60,20,30,30,0,1,1, deepcopy(init_generator_history))
#generator2 = Generator("Gen2",0,0,30,50,30,0,1,-1, deepcopy(init_generator_history)) #name, g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_quantity(MWh), profit(€)
#generator3 = Generator("Gen3",0,0,60,80,40,0,1,1, deepcopy(init_generator_history)) #name, g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_quantity(MWh), profit(€)
#Generators = [generator1,generator2,generator3]
Generators = [generator1]
ThisGeneratorPortfolio = GeneratorPortfolio(Generators)
init_holding_history = HoldingCompanyHistory([],[],[],[])
ThisHoldingCompany = HoldingCompany("Firm1",ThisGeneratorPortfolio,Consumers,deepcopy(init_holding_history))

ThisMarketOperator = MarketOperator("MO",ThisHoldingCompany.generator_portfolio.generators_included,Consumers)

#OptimizeBidding(ThisHoldingCompany)
#sort!(Consumers, by = x -> x.VoLL, rev=true)
#sort!(Generators, by = x -> x.marginal_cost)

#status, price = OptimizeBidding(ThisHoldingCompany)
#println("Profit maximizing clear price", price)

#println([Consumers[i].VoLL for i in 1:num_of_consumer])

#println("clear price: ", clear(ThisMarketOperator), " €/MWh")
#PlotTrade(ThisMarketOperator)

include("RunSimulation.jl")
RunSimulation(ThisMarketOperator,ThisHoldingCompany,5000)

PyPlot.figure(2)
PyPlot.plot(ThisHoldingCompany.history.profit_history)
PyPlot.figure(3)
PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.offer_quantity_history)

PyPlot.figure(4)
PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.quantity_decision_history)

PyPlot.figure(5)
PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.price_decision_history)

PyPlot.figure(6)
PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.clear_price_history)
