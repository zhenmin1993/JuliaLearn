abstract type Node end
abstract type PhysicalNode <: Node end
abstract type Technology <: PhysicalNode end
abstract type SocialNode <: Node end
abstract type Agent <: SocialNode end
abstract type ActiveAgent <: Agent end
abstract type PassiveAgent <: Agent end


abstract type Edge end
abstract type PhysicalEdge <: Edge end

abstract type SocialEdge <: Edge end
abstract type Contract <: SocialEdge end
abstract type Ownership <: SocialEdge end

abstract type Property end


abstract type Buffer end

abstract type Factors end
abstract type FutureProjection <: Factors end




mutable struct OperationalConfiguration
    capacityWithhold::Float64
    priceMarkUp::Float64
end

mutable struct DesignProperty <: Property
    availability::Float64
    constructionTimeStamp::Float64
    constructionTime::Float64
    deconstructionTime::Float64
    efficiency::Float64
    lifeTime::Float64
    maxCapacity::Float64
    minCapacity::Float64
end

struct EconomicProperty <: Property
    constructionCost::Float64
    deconstructionCost::Float64
    maintenanceCost::Float64
    variableCost::Float64
    fixedCost::Float64
end

struct Status
    online::Bool
end

mutable struct ConventionalPlants <: Technology
    name::String
    currentOperationalConfiguration::OperationalConfiguration
    designProperties::DesignProperty
    economicProperties::EconomicProperty
    status::Status
    offerPrice::Float64
    offerQuantity::Float64
end

mutable struct RenewablePlants <:Technology
    name::String
    currentOperationalConfiguration::OperationalConfiguration
    designProperties::DesignProperty
    economicProperties::EconomicProperty
    status::Status
    offerPrice::Float64
    offerQuantity::Float64
    capacityFactors::Vector{Float64}
end

mutable struct FinancialCondition
    cash::Float64
    dailyProfit::Float64
    netAsset::Float64
    totalDebt::Float64
end

mutable struct GenCo <: ActiveAgent
    name::String
    financialCondition::FinancialCondition
    technologies::Vector{Technology}
end

mutable struct DemandProjectionFactors <: FutureProjection
    demandProjection::Vector{Float64}
end

mutable struct VoLLProjectionFactors <: FutureProjection
    vollProjection::Vector{Float64}
end

mutable struct DailyDemandFactors <: Factors
    dailyDemand::Vector{Float64}
end

mutable struct WeightFactors <: Factors
    weights::Vector{Float64}
end

mutable struct Consumer <: PassiveAgent
    name::String
    baseDemand::Float64 #Assume the average demand is 1 unit
    dailyDemandFactors::DailyDemandFactors
    demand::Float64
    VoLL::Float64
    demandProjection::DemandProjectionFactors
    vollProjection::VoLLProjectionFactors
end

mutable struct ConsumerGroup <: PassiveAgent
    allConsumers::Vector{Consumer}
    totalConsumption::Float64
    priceCap::Float64
end

mutable struct MarketOperator <: PassiveAgent
    name::String
end

mutable struct SpotMarketContract <: Contract
    from::Agent
    to::Agent
    marketPrice::Float64
end

mutable struct GenCoOwnership <: Ownership
    from::Agent
    to::Node
end

mutable struct PowerFlow <: PhysicalEdge
    from::Node
    to::Node
    quantity::Float64
    marketPrice::Float64
end

mutable struct SystemHistory <: Buffer
    systemCapacityMix::Vector{Vector{Technology}}
end
