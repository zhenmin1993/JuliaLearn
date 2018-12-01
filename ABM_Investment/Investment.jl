

function HourlyAuction(newTechnology::Technology, allGenerators::Vector{Technology}, allConsumers::Vector{Consumer},allPowerFlows::Vector{PowerFlow})
    hourlyProfit = 0
    if newTechnology.designProperties.availability < rand(1)[1]
        hourlyProfit = -newTechnology.economicProperties.maintenanceCost
    else
        Clear(allGenerators, allConsumers, allPowerFlows)
        hourlyPowerFlow = MatchPowerFlow(newTechnology, allPowerFlows)
        marketPrice = hourlyPowerFlow.marketPrice
        hourlyProfit = (marketPrice - newTechnology.economicProperties.variableCost) * hourlyPowerFlow.quantity
    end
    return hourlyProfit
end


function DemandChange(allConsumers::Vector{Consumer}, hour::Int64)
    for consumer in allConsumers
        consumer.demand = consumer.baseDemand * consumer.dailyDemandFactors.dailyDemand[hour]
    end
end

function SupplyChange(allGenerators::Vector{Technology}, hour::Int64)
    for generator in allGenerators
        if typeof(generator) == RenewablePlants
            generator.offerQuantity = generator.designProperties.maxCapacity * generator.capacityFactors[hour]
        end
    end
end

function CalculateNPV(newTechnology::Technology, profitStream::Vector{Float64}, interestRate::Float64)
    yearlyDiscountFactor = exp(-interestRate)
    constructionCost = newTechnology.economicProperties.constructionCost
    deconstructionCost = newTechnology.economicProperties.deconstructionCost
    lifeTime = newTechnology.designProperties.lifeTime
    NPV = -constructionCost
    yearVector = 0:1:(lifeTime-1)
    lifeDiscountVector = exp.(-interestRate * yearVector)
    #for year in 1:lifeTime
        #NPV += exp(-interestRate * (year-1)) * profitStream[Int64(year)]
    #end
    NPV += lifeDiscountVector' * profitStream
    NPV += -deconstructionCost * exp(-interestRate * lifeTime)
    return NPV
end

function EvaluateTechnology(newTechnology::Technology, weightFactors::WeightFactors, interestRate::Float64,allGenerators::Vector{Technology}, allConsumers::Vector{Consumer},allPowerFlows::Vector{PowerFlow})
    profitStream = Vector{Float64}(0)
    foresightHorizon = newTechnology.designProperties.lifeTime
    milestoneYear = 5
    year2day = 12
    day2hour = 24
    for year in 1:foresightHorizon
        unweightedDailyProfit = Vector{Float64}(0)
        for day in 1:year2day
            dailyProfit = 0.0
            for hour in 1:day2hour
                DemandChange(allConsumers, hour)
                SupplyChange(allGenerators, hour)
                #println("number of flows: ",length(allPowerFlows))
                thisProfit = HourlyAuction(newTechnology, allGenerators, allConsumers, allPowerFlows)
                dailyProfit += thisProfit
            end
            push!(unweightedDailyProfit, dailyProfit)
        end
        yearlyProfit = unweightedDailyProfit' * weightFactors.weights
        push!(profitStream, yearlyProfit)
    end
    NPV = CalculateNPV(newTechnology, profitStream, interestRate)
    return NPV
end

function InvestmentDecision(genCo::GenCo, MO::MarketOperator, technologyPool::Vector{Technology}, weightFactors::WeightFactors, year::Real,interestRate::Float64,allGenerators::Vector{Technology}, allConsumers::Vector{Consumer},allPowerFlows::Vector{PowerFlow}, allOwnerShips::Vector{GenCoOwnership})
    maxNPV = -Inf
    investIndicator = 0
    bestTechnology = Vector{Technology}(0)
    for newTechnology in technologyPool
        if newTechnology.economicProperties.constructionCost * 0.3 < genCo.financialCondition.cash
            investIndicator = 1
            push!(allGenerators, newTechnology)
            thisPowerFlow = PowerFlow(newTechnology, MO, 0,0)
            push!(allPowerFlows, thisPowerFlow)
            thisNPV = EvaluateTechnology(newTechnology,weightFactors, interestRate,allGenerators, allConsumers,allPowerFlows)
            println("NPV of technology: ", newTechnology.name, " ",thisNPV)
            println("total generators: ", length(allGenerators))
            deleteat!(allGenerators, findin(allGenerators, [newTechnology]))
            deleteat!(allPowerFlows, findin(allPowerFlows, [thisPowerFlow]))
            if thisNPV > maxNPV && thisNPV > 0
                investIndicator = 1
                maxNPV = deepcopy(thisNPV)
                push!(bestTechnology, newTechnology)
                if length(bestTechnology) >1
                    deleteat!(bestTechnology, 1)
                end
                println("Best generator: ", bestTechnology[1].name)
            end
        end
    end

    if investIndicator == 1
        investTechnology = deepcopy(bestTechnology[1])
        investTechnology.designProperties.constructionTimeStamp = year
        push!(genCo.technologies, investTechnology)
        genCo.financialCondition.cash += (-investTechnology.economicProperties.constructionCost)
        push!(allOwnerShips, GenCoOwnership(genCo,investTechnology))
        push!(allPowerFlows, PowerFlow(investTechnology, MO, 0,0))
        push!(allGenerators,investTechnology)
        #return investTechnology, maxNPV
    end
end

function Decommission(allGenerators::Vector{Technology}, allPowerFlows::Vector{PowerFlow},allOwnerShips::Vector{GenCoOwnership}, year::Real)
    generatorsToDecommission = Vector{Technology}(0)
    ownershipsToDelete = Vector{GenCoOwnership}(0)
    powerflowsToDelete = Vector{PowerFlow}(0)
    for generator in allGenerators
        if generator.designProperties.constructionTimeStamp + generator.designProperties.lifeTime <= year
            thisOwnerShip = MatchOwnership(generator,allOwnerShips)
            thisOwnerShip.from.financialCondition.cash += (-generator.designProperties.deconstructionCost)
            thisPowerFlow = MatchPowerFlow(generator,allPowerFlows)
            push!(generatorsToDecommission, generator)
            push!(ownershipsToDelete, thisOwnerShip)
            push!(powerflowsToDelete, thisPowerFlow)
        end
    end
    deleteat!(allOwnerShips, findin(allOwnerShips, ownershipsToDelete))
    deleteat!(allPowerFlows, findin(allPowerFlows, powerflowsToDelete))
    deleteat!(allGenerators, findin(allGenerators, generatorsToDecommission))
    println("OwnerShips after delete: ", length(allOwnerShips))
end

function SimulateInvestment(totalHorizon::Float64, MO::MarketOperator, allGenCos::Vector{GenCo}, technologyPool::Vector{Technology}, weightFactors::WeightFactors, interestRate::Float64,allGenerators::Vector{Technology}, allConsumers::Vector{Consumer},allPowerFlows::Vector{PowerFlow}, allOwnerShips::Vector{GenCoOwnership}, systemHistory::SystemHistory)
    year2day = 12
    day2hour = 24

    for year in 1:totalHorizon
        println("This is year ", year)
        Decommission(allGenerators, allPowerFlows,allOwnerShips, year)
        if year % 5 == 0 || year == 1
            sequence = rand(1:length(allGenCos),length(allGenCos))
            for i in sequence
                println("Now invetment GenCo: ", i)
                thisGenCo = allGenCos[i]
                InvestmentDecision(thisGenCo, MO,technologyPool, weightFactors, year,interestRate,allGenerators, allConsumers,allPowerFlows,allOwnerShips)
            end
        end

        for day in 1:year2day
            for hour in 1:day2hour
                DemandChange(allConsumers, hour)
                SupplyChange(allGenerators, hour)
                Clear(allGenerators, allConsumers, allPowerFlows)
                Payment(allPowerFlows, allOwnerShips)
                #push!(dailyProfitStream, thisProfit)
            end
            for genCo in allGenCos
                genCo.financialCondition.cash += genCo.financialCondition.dailyProfit * weightFactors.weights[day]
                genCo.financialCondition.dailyProfit = 0
            end
        end
        for genCo in allGenCos
            println("GenCo ",genCo.name," cash: ",genCo.financialCondition.cash)
        end
        push!(systemHistory.systemCapacityMix, deepcopy(allGenerators))
    end
end
