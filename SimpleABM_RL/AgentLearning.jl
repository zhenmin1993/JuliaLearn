

mutable struct State
    position::Int8 #position = 1,0,-1 => totally in money, marginal, out of money
    market_price::Float64
    profit::Float64
end

struct Action
    action::Tuple{Int8,Int8} #price, quantity
end

actionSpace = Vector{Action}(0)
for a in collect(Iterators.product(-1:1, -1:1))
    push!(actionSpace, Action(a))
end

struct StateActionPair
    state::State
    action::Action
    Q::Float64
end

struct QBuffer
    buffer::Vector{StateActionPair}
end



struct OneStep
    s::State
    a::Action
    r::Float64
    s_next::State
end

function OptAction(currentState::State, qbuffer::QBuffer)
    find = 0
    for sapair in qbuffer.buffer
        if currentState == sapair
            find = 1
        end
    end

end
