import PyPlot

include("AgentDefine.jl")
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

init_generator_history = GeneratorHistory([],[],[],[],[],[],[],[])
init_holding_history = HoldingCompanyHistory([],[],[],[],[],[],[])
VirtualGenerator =  Generator("Virtual","Init",0,0,200,200,0,0,0,0, deepcopy(init_generator_history))
init_generator_portfolio = GeneratorPortfolio([VirtualGenerator], 0)
init_holding_company = HoldingCompany("Init",init_generator_portfolio,Consumers,1,1,deepcopy(init_holding_history))
#name, owner,g_min(MWh), g_max(MWh), marginal_cost(€/MWh), offer_price(€/MWh), offer_quantity(MWh), profit(€), price decision,quantity decision, history
generator1 = Generator("Gen1","Init",0,5,5,5,3,0,1,1, deepcopy(init_generator_history))
generator2 = Generator("Gen2","Init",0,8,8,8,5,0,-1,1, deepcopy(init_generator_history))
generator3 = Generator("Gen3","Init",2,8,9,9,4,0,-1,1, deepcopy(init_generator_history))
generator4 = Generator("Gen4","Init",5,8,10,10,6,0,1,1, deepcopy(init_generator_history))
generator5 = Generator("Gen5","Init",3,9,12,12,5,0,-1,1, deepcopy(init_generator_history))
generator6 = Generator("Gen6","Init",2,6,15,15,3,0,1,1, deepcopy(init_generator_history))
generator7 = Generator("Gen7","Init",1,5,18,18,2,0,-1,1, deepcopy(init_generator_history))
generator8 = Generator("Gen8","Init",0,3,20,20,2,0,1,1, deepcopy(init_generator_history))
generator9 = Generator("Gen9","Init",2,4,23,23,2,0,-1,1, deepcopy(init_generator_history))
generator10 = Generator("Gen10","Init",1,5,26,26,3,0,1,1, deepcopy(init_generator_history))
generator11 = Generator("Gen11","Init",0,15,30,30,8,0,-1,1, deepcopy(init_generator_history))
generator12 = Generator("Gen12","Init",2,10,31,31,4,0,1,1, deepcopy(init_generator_history))
generator13 = Generator("Gen13","Init",5,20,32,32,9,0,-1,1, deepcopy(init_generator_history))
generator14 = Generator("Gen14","Init",1,15,35,35,11,0,1,1, deepcopy(init_generator_history))
generator15 = Generator("Gen15","Init",2,10,38,38,6,0,-1,1, deepcopy(init_generator_history))
AllTechnologies_competitive = [generator1,generator2,generator3,generator4,generator5,generator6,generator7,generator8,generator9,generator10,generator11,generator12,generator13,generator14,generator15]

generator_monopoly = Generator("Gen_mono","Init",0,60,20,20,60,0,1,1, deepcopy(init_generator_history))
AllTechnologies_monopoly = [generator_monopoly]

generator_oligopoly_1 = Generator("Gen_olig_1","Init",0,25,10,10,25,0,1,1, deepcopy(init_generator_history))
generator_oligopoly_2 = Generator("Gen_olig_2","Init",0,25,10,10,25,0,-1,1, deepcopy(init_generator_history))
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
        ThisHoldingCompany = HoldingCompany(company_name,deepcopy(init_generator_portfolio),Consumers,1,1,deepcopy(init_holding_history))
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
        ThisHoldingCompany = HoldingCompany(company_name,deepcopy(init_generator_portfolio),Consumers,1,1,deepcopy(init_holding_history))
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
RunSimulation(ThisMarketOperator,HoldingCompanies,4000)

if case == "Monopoly"
    status, quantity, price = OptimizeBidding(HoldingCompanies[1], ThisConsumerGroup)
    println("Profit maximizing quantity ", quantity)
    println("Profit maximizing price ", price)
end
