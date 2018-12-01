import PyPlot

include("AgentDefine.jl")
include("AgentLearning.jl")

include("MarketClearing.jl")
include("TradePlot.jl")
include("OfferOptimize.jl")

num_of_generator = 3
num_of_consumer = 10000


Consumers = Vector{Consumer}(0)
init_consumer_history = ConsumerHistory([],[],[])
price_cap = 200 #€/MWh
consumption_min = 1 #kWh
consumption_max = 12 #kWh
srand(1234)
for i in 1:num_of_consumer
    new_consumer = Consumer("Con$i", rand(consumption_min:0.1:consumption_max,1)[1], rand(1:5:price_cap,1)[1], deepcopy(init_consumer_history))
    push!(Consumers, new_consumer)
    #println(new_consumer.name)
end

ThisConsumerGroup = ConsumerGroup(Consumers,0.0,price_cap)

function CalculateTotalConsumption(consumergroup::ConsumerGroup)
    for i in 1:length(consumergroup.allconsumers)
        consumergroup.total_consumption = consumergroup.total_consumption + ThisConsumerGroup.allconsumers[i].demand / 1000
    end
end

CalculateTotalConsumption(ThisConsumerGroup)
println(ThisConsumerGroup.total_consumption)

init_decision = Action((0,0))
init_State = State(0,0,0,0,0)
init_Q_buffer = QBuffer(Vector{StateActionPairs}(0))
init_generator_history = GeneratorHistory(Vector{Float64}(0),Vector{Float64}(0),Vector{Float64}(0),Vector{Float64}(0),Vector{Float64}(0),Vector{Float64}(0),Vector{Action}(0))
init_holding_history = HoldingCompanyHistory(Vector{Generator}(0),Vector{Float64}(0),Vector{Float64}(0),Vector{Float64}(0),Vector{Float64}(0),Vector{Action}(0),deepcopy(init_Q_buffer))
VirtualGenerator =  Generator("Virtual","Init",0,0,200,200,0,0,init_decision, deepcopy(init_generator_history))
init_generator_portfolio = GeneratorPortfolio([VirtualGenerator], 0)
init_holding_company = HoldingCompany("Init",init_generator_portfolio,Consumers,init_decision,init_State,deepcopy(init_holding_history))

AllTechnologies_competitive = Vector{Generator}(0)

for gen_num in 1:length(g_min)
    gen_name = string("Gen", string(gen_num))
    #name, owner,g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_quantity(MWh), profit(€), price decision,quantity decision, history
    push!(AllTechnologies_competitive, Generator(gen_name, "Init", g_min[gen_num], g_max[gen_num], marginal_cost[gen_num],marginal_cost[gen_num], g_max[gen_num],0,init_decision, deepcopy(init_generator_history)))
end

#AllTechnologies_competitive = [generator1,generator2,generator3,generator4,generator5,generator6,generator7,generator8,generator9,generator10,generator11,generator12,generator13,generator14,generator15]

generator_monopoly = Generator("Gen_mono","Init",0,60,20,20,60,0,init_decision, deepcopy(init_generator_history))
AllTechnologies_monopoly = [generator_monopoly]

generator_oligopoly_1 = Generator("Gen_olig_1","Init",0,25,10,10,25,0,init_decision, deepcopy(init_generator_history))
generator_oligopoly_2 = Generator("Gen_olig_2","Init",0,25,10,10,25,0,init_decision, deepcopy(init_generator_history))
AllTechnologies_oligopoly = [generator_oligopoly_1,generator_oligopoly_2]


function CheckInBetween(rand_num::Float64, segments::Integer)
    place = 0
    for i in 1:segments
        if rand_num >= (i-1)/segments && rand_num < i/segments
            place = i
            break
        end
    end
    return Int(place)
end

case_list = ["Monopoly","Oligopoly","Competitive"]
case = case_list[2]

if case == "Monopoly"
    total_company_num = 1
    HoldingCompanies = Vector{HoldingCompany}(0)
    for company_num in 1:total_company_num
        company_name = string("Firm", string(company_num))
        ThisHoldingCompany = HoldingCompany(company_name,deepcopy(init_generator_portfolio),Consumers,init_decision,init_State,deepcopy(init_holding_history))
        push!(HoldingCompanies, ThisHoldingCompany)
    end

    AllTechnologies = AllTechnologies_monopoly
    tech_allocation = 0
    for tech in AllTechnologies
        tech_allocation += 1
        tech.owner = HoldingCompanies[tech_allocation].name
        push!(HoldingCompanies[tech_allocation].generator_portfolio.generators_included , tech)
        HoldingCompanies[tech_allocation].generator_portfolio.total_generator_num += 1
    end
end

if case == "Oligopoly"
    total_company_num = 15
    HoldingCompanies = Vector{HoldingCompany}(0)
    for company_num in 1:total_company_num
        company_name = string("Firm", string(company_num))
        ThisHoldingCompany = HoldingCompany(company_name,deepcopy(init_generator_portfolio),Consumers,init_decision,init_State,deepcopy(init_holding_history))
        push!(HoldingCompanies, ThisHoldingCompany)
    end

    AllTechnologies = AllTechnologies_competitive
    tech_allocation = 0
    for tech in AllTechnologies
        tech_allocation += 1
        tech.owner = HoldingCompanies[tech_allocation].name
        push!(HoldingCompanies[tech_allocation].generator_portfolio.generators_included , tech)
        HoldingCompanies[tech_allocation].generator_portfolio.total_generator_num += 1
    end
end

if case == "Competitive"
    total_company_num = 4
    HoldingCompanies = Vector{HoldingCompany}(0)
    for company_num in 1:total_company_num
        company_name = string("Firm", string(company_num))
        ThisHoldingCompany = HoldingCompany(company_name,deepcopy(init_generator_portfolio),Consumers,1,1,deepcopy(init_holding_history))
        push!(HoldingCompanies, ThisHoldingCompany)
    end


    AllTechnologies = AllTechnologies_competitive
    for tech in AllTechnologies
        this_rand = rand(1)[1]
        tech_allocation = CheckInBetween(this_rand,total_company_num)

        tech.owner = HoldingCompanies[tech_allocation].name
        push!(HoldingCompanies[tech_allocation].generator_portfolio.generators_included , tech)
        HoldingCompanies[tech_allocation].generator_portfolio.total_generator_num += 1
    end
end



#HoldingCompanies = [FirstHoldingCompany, SecondHoldingCompany,ThirdHoldingCompany,FourthHoldingCompany]
ThisMarketOperator = MarketOperator("MO",HoldingCompanies,Consumers)




#println([Consumers[i].VoLL for i in 1:num_of_consumer])

#println("clear price: ", clear(ThisMarketOperator), " €/MWh")
#PlotTrade(ThisMarketOperator)

include("RunSimulation.jl")
ExplorationSimulation(ThisMarketOperator,HoldingCompanies,8000)
RealSimulation(ThisMarketOperator,HoldingCompanies,1000,8000)

if case == "Monopoly"
    status, quantity, price = OptimizeBidding(HoldingCompanies[1], ThisConsumerGroup)
    println("Profit maximizing quantity ", quantity)
    println("Profit maximizing price ", price)
end
