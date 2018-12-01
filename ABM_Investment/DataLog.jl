totalHorizon = 10.0
interestRate = 0.02

###Technology parameters
technologyType = ["thermal","thermal", "wind", "solar",  "wind"]
#OperationalConfiguration
capacityWithhold = [0,0,0,0,0,0]
priceMarkUp = [0.2,0.2,0.2,0.2,0.2]

#DesignProperty
availability = [0.95,0.99,0.93,0.92,0.98]
constructionTimeStamp = [-1,-2,-1,-2,-1]
constructionTime = [1,1,1,1,1]
deconstructionTime = [1,1,1,1,1]
efficiency = [0.95,0.95,0.95,0.95,0.95]
lifeTime = [20,20,15,10,18]
maxCapacity = [2,6,2,4,3]
minCapacity = [1,1,2,1,1]

#EconomicProperty
constructionCost = [1e6,2e6,3e5,1.5e6,2.2e6]
deconstructionCost = [2e5,4e5, 3e4, 3e5,4.5e5]
maintenanceCost = [1,1,1.5,2,1.5] #€/MWh(daily) and €/MW(yearly)
variableCost = [5,8,3,3,1]
fixedCost = [3,4,2,4,3]

##Agent
#FinancialCondition
cash = [1e6, 1e6]


##Factors
#Capacity factors
capacityFactors_Wind = [1,1,1,1,1,1,1,0.9,0.8,0.7,0.6,0.4,0.3,0.3,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1,1,1]
capacityFactors_Solar = [0,0,0,0,0,0,0.1,0.3,0.6,1,1,1,1,1,1,1,0.7,0.2,0,0,0,0,0,0]

#representative day factors
representativeDayWeightFactors = [30,30,30,25,23,30,40,35,35,25,25,38]

#Daily demand level factors (assume the average of each day is 1)
dailyDemandFactors = [0.15, 0.15, 0.1, 0.1, 0.1, 0.15,0.2, 0.5, 1.1, 1.3, 0.8,0.5,0.4, 0.9,1.1, 0.8,0.7,0.5, 1.1, 1.3, 1.6, 1.1, 0.9, 0.3]

#Demand projection factors, as compared with the starting year
demandProjection = ones(totalHorizon)
vollProjection = ones(totalHorizon)
