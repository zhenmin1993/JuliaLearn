
abstract type History{T} end
abstract type BiddingHistory{T} <: History{T} end
abstract type DispatchHistory{T} <: History{T} end



mutable struct GeneratorHistory{Float64} <: BiddingHistory{Float64}
    amount_history::Vector{Float64}
    price_history::Vector{Float64}
    profit_history::Vector{Float64}
end
mutable struct Generator
    name::String
    g_min::Float64
    g_max::Float64
    #fixed_cost::Float64
    #variable_cost::Float64
    marginal_cost::Float64
    offer_price::Float64
    offer_amount::Float64
    profit::Float64
    history::GeneratorHistory
end


mutable struct ConsumerHistory{Float64} <: BiddingHistory{Float64}
    amount_history::Vector{Float64}
    price_history::Vector{Float64}
    value_history::Vector{Float64}
end
mutable struct Consumer
    name::String
    demand::Float64
    VoLL::Float64
    history::ConsumerHistory
end




mutable struct HoldingCompnayHistory{Generator} <:DispatchHistory{Generator}
    dispatch_history::Vector{Vector{Generator}}
    profit_history::Vector{Float64}
end
mutable struct HoldingCompany{Generator,Consumer,HoldingCompanyHistory}
    name::String
    generator_portfolio::Vector{Generator}
    allconsumers::Vector{Consumer}
    dispatch_history::HoldingCompanyHistory

end

mutable struct ConsumerGroup{Consumer}
    allconsumers::Vector{Consumer}
    total_consumption::Float64
end
