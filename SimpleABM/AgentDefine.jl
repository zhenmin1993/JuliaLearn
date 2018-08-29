abstract type Agent end
mutable struct Generator <:Agent
    Profit <: Number
    #FixedCost <: Number
    #VariableCost <:Number
    #Revenue <: Number
    #Dispatch <: Number
end

mutable struct Consumer <:Agent
    VoLL <: Number
    Demand <: Number
end

function Trade(GeneratorGroup::Array{Generator},ConsumerGroup::Array{Consumer})
end
