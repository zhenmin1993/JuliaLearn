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
generator1 = Generator("Gen1",0,10,10,13,5,0,1,1, deepcopy(init_generator_history))
generator2 = Generator("Gen2",0,8,12,15,6,0,1,1, deepcopy(init_generator_history))
generator3 = Generator("Gen3",2,8,15,28,5,0,1,1, deepcopy(init_generator_history))
generator4 = Generator("Gen4",5,8,20,25,7,0,1,1, deepcopy(init_generator_history))
generator5 = Generator("Gen5",3,9,25,28,8,0,1,1, deepcopy(init_generator_history))
generator6 = Generator("Gen6",2,6,27,30,5,0,1,1, deepcopy(init_generator_history))
generator7 = Generator("Gen7",1,5,28,30,4,0,1,1, deepcopy(init_generator_history))
generator8 = Generator("Gen8",0,3,30,31,2,0,1,1, deepcopy(init_generator_history))
generator9 = Generator("Gen9",2,4,32,35,3,0,1,1, deepcopy(init_generator_history))
generator10 = Generator("Gen10",1,5,33,36,4,0,1,1, deepcopy(init_generator_history))
VirtualGenerator =  Generator("Virtual",0,0,200,200,0,0,0,0, deepcopy(init_generator_history))
Generators = [generator1,generator2,generator3,generator4,generator5,generator6,generator7,generator8,generator9,generator10,VirtualGenerator]
#Generators = [generator1]
ThisGeneratorPortfolio = GeneratorPortfolio(Generators, length(Generators)-1)
init_holding_history = HoldingCompanyHistory([],[],[],[],[],[],[])
ThisHoldingCompany = HoldingCompany("Firm1",ThisGeneratorPortfolio,Consumers,1,1,deepcopy(init_holding_history))

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

figure = 2
PyPlot.figure(figure)
PyPlot.plot(ThisHoldingCompany.history.profit_history)

#figure += 1
#PyPlot.figure(figure)
#PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.offer_quantity_history)

#figure += 1
#PyPlot.figure(4)
#PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.quantity_decision_history)

figure += 1
PyPlot.figure(figure)
PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.price_decision_history)

figure += 1
PyPlot.figure(figure)
PyPlot.plot(ThisHoldingCompany.generator_portfolio.generators_included[1].history.clear_price_history)
