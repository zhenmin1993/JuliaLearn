

include("BasicElements.jl")
include("MarketClearing.jl")
include("Investment.jl")


#Initialize technologies
initOperationConfiguration = OperationalConfiguration(0,0.2)

initStatus = Status(true)

technologyPool = Vector{Technology}(0)
thermalCount = 0
windCount = 0
solarCount = 0
for i in 1:length(technologyType)
    thisDesignProperty = DesignProperty(availability[i], constructionTimeStamp[i],constructionTime[i],deconstructionTime[i],efficiency[i],lifeTime[i],maxCapacity[i],minCapacity[i])
    thisEconomicProperty = EconomicProperty(constructionCost[i], deconstructionCost[i], maintenanceCost[i], variableCost[i], fixedCost[i])
    thisOfferPrice = (initOperationConfiguration.priceMarkUp + 1) * variableCost[i]
    if technologyType[i] == "thermal"
        thermalCount += 1
        name = string(technologyType[i], thermalCount)
        push!(technologyPool, ConventionalPlants(name,initOperationConfiguration, thisDesignProperty, thisEconomicProperty,initStatus,thisOfferPrice, thisDesignProperty.maxCapacity))
    end
    if technologyType[i] == "wind"
        windCount += 1
        name = string(technologyType[i], windCount)
        push!(technologyPool, RenewablePlants(name, initOperationConfiguration, thisDesignProperty,thisEconomicProperty,initStatus,thisOfferPrice, thisDesignProperty.maxCapacity,capacityFactors_Wind))
    end
    if technologyType[i] == "solar"
        solarCount += 1
        name = string(technologyType[i], solarCount)
        push!(technologyPool, RenewablePlants(name, initOperationConfiguration, thisDesignProperty, thisEconomicProperty,initStatus,thisOfferPrice, thisDesignProperty.maxCapacity,capacityFactors_Solar))
    end
end

#Initialize GenCos and ownerships
srand(1234)
systemCapacityMix = Vector{Vector{Technology}}(0)
systemHistory = SystemHistory(systemCapacityMix)
allGenerators = Vector{Technology}(0)
allOwnerShips = Vector{GenCoOwnership}(0)
allGenCos = Vector{GenCo}(0)
numGenCo = 2
GenCoPlantNum = [6,8]
for i in 1:numGenCo
    thisName = string("GenCo", i)
    thisFinancialCondition = FinancialCondition(cash[i], 0,0,0)
    thisTechnologies = Vector{Technology}(0)
    thisGenCo = GenCo(thisName, thisFinancialCondition, thisTechnologies)
    for j in 1:GenCoPlantNum[i]
        thisTechnology = deepcopy(technologyPool[rand(1:1:5)])
        push!(thisGenCo.technologies, thisTechnology)
        thisOwnerShip = GenCoOwnership(thisGenCo, thisTechnology)
        push!(allOwnerShips,thisOwnerShip)
        push!(allGenerators, thisTechnology)
    end
    push!(allGenCos,thisGenCo)
end
push!(systemHistory.systemCapacityMix, allGenerators)

println("OwnerShips: ", length(allOwnerShips))
#Initialize consumers
allConsumers = Vector{Consumer}(0)
num_of_consumer = 10000
price_cap = 200 #€/MWh
consumption_min = 1 #kWh
consumption_max = 12 #kWh
srand(1234)
for i in 1:num_of_consumer
    newConsumer = Consumer("Con$i", rand(consumption_min:0.1:consumption_max,1)[1],DailyDemandFactors(dailyDemandFactors), 0,rand(1:5:price_cap,1)[1], DemandProjectionFactors(demandProjection),VoLLProjectionFactors(vollProjection))
    push!(allConsumers, newConsumer)
end


#Initialize consumers
MO = MarketOperator("MarketOperator")

#Initialize powerflows
allPowerFlows = Vector{PowerFlow}(0)
for generator in allGenerators
    thisPowerFlow = PowerFlow(generator, MO, 0,0)
    push!(allPowerFlows, thisPowerFlow)
end

weightFactors = WeightFactors(representativeDayWeightFactors)

SimulateInvestment(totalHorizon, MO, allGenCos, technologyPool, weightFactors, interestRate,allGenerators, allConsumers,allPowerFlows,allOwnerShips, systemHistory)
