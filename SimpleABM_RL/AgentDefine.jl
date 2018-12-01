
abstract type History{T} end
abstract type BiddingHistory{T} <: History{T} end
abstract type DispatchHistory{T} <: History{T} end


struct Action
    action::Tuple{Int8,Int8} #price, quantity
end

mutable struct State
    agentPosition::Int8 #position = 1,0,-1 => totally in money, marginal, out of money
    offer_price::Float64
    offer_quantity::Float64
    market_price::Float64
    profit::Float64
end

mutable struct StateActionPairs
    state::State
    actionSpace::Vector{Action}
    Q_list::Vector{Float64}
    actionCount::Vector{Int64}
end

mutable struct QBuffer
    buffer::Vector{StateActionPairs}
end

mutable struct GeneratorHistory
    offer_quantity_history::Vector{Float64}
    offer_price_history::Vector{Float64}
    price_estimation_history::Vector{Float64}
    profit_history::Vector{Float64}
    clear_price_history::Vector{Float64}
    real_quantity_history::Vector{Float64}
    decision_history::Vector{Action}
end
mutable struct Generator
    name::String
    owner::String
    g_min::Float64
    g_max::Float64
    #fixed_cost::Float64
    #variable_cost::Float64
    marginal_cost::Float64
    offer_price::Float64
    offer_quantity::Float64
    profit::Float64
    decision::Action
    history::GeneratorHistory
end


mutable struct ConsumerHistory{Float64} <: BiddingHistory{Float64}
    quantity_history::Vector{Float64}
    price_history::Vector{Float64}
    value_history::Vector{Float64}
end
mutable struct Consumer
    name::String
    demand::Float64
    VoLL::Float64
    history::ConsumerHistory
end



mutable struct GeneratorPortfolio
    generators_included::Vector{Generator}
    total_generator_num::Int8
end
mutable struct HoldingCompanyHistory
    dispatch_history::Vector{Generator}
    profit_history::Vector{Float64}
    clear_price_history::Vector{Float64}
    max_dispatch_price_history::Vector{Float64}
    min_dispatch_price_history::Vector{Float64}
    decision_history::Vector{Action}
    qbuffer::QBuffer
end
mutable struct HoldingCompany
    name::String
    generator_portfolio::GeneratorPortfolio
    allconsumers::Vector{Consumer}
    decision::Action
    previous_state::State
    history::HoldingCompanyHistory
end

mutable struct ConsumerGroup
    allconsumers::Vector{Consumer}
    total_consumption::Float64
    price_cap::Float64
end
