
function JudgePosition(offer_price::Float64, market_price::Float64)
    if offer_price > market_price
        return -1
    end

    if offer_price == market_price
        return 0
    end

    if offer_price < market_price
        return 1
    end
end






function GenerateActionSpaceQTable(priceCap::Float64, priceFloor::Float64, quantityCap::Float64, quantityFloor::Float64)
    actionSpace = Vector{Action}(0)
    priceStep = round((priceCap - priceFloor)/10)
    quantityStep = round((quantityCap - quantityFloor)/10)
    for a in collect(Iterators.product(priceFloor:priceStep:priceCap, quantityFloor:quantityStep:quantityCap))
        push!(actionSpace, Action(a))
    end
    initial_Q_list = zeros(length(actionSpace))
    initial_actionCount = Vector{Int64}(0)
    for a in 1:length(actionSpace)
        push!(initial_actionCount, Int64(1))
    end
    return actionSpace,initial_Q_list,initial_actionCount
end







function EpsilonGreedy(progress_index::Float64)
    explore = true
    exploitation = false
    deviate = false
    if progress_index > rand(1)[1] #explore
        deviate = explore
    end
    if progress_index <= rand(1)[1] #exploitation
        deviate = exploitation
    end
    return deviate
end

function findOptAction(currentStateActionPairs::StateActionPairs, progress_index::Float64)
    optActionTag = 1
    optQTag = 1
    for i in 2:length(currentStateActionPairs.Q_list)
        if currentStateActionPairs.Q_list[i] > currentStateActionPairs.Q_list[optQTag]
            optActionTag = i
        end
    end
    if EpsilonGreedy(progress_index)
        optActionTag = rand(1:1:length(currentStateActionPairs.Q_list),1)[1]
    end
    return currentStateActionPairs.actionSpace[optActionTag]
end





struct OneStep
    s::State
    a::Action
    r::Float64
    s_next::State
end

function ConfrontNewState(newState::State, actionSpace::Vector{Action}, initial_Q_list::Vector{Float64},initial_actionCount::Vector{Int64})
    return StateActionPairs(newState, actionSpace, initial_Q_list,initial_actionCount)
end

function updateQBuffer!(currentState::State, decision::Action, qbuffer::QBuffer, newReward,total_episodes::Int64)
    for sapair in qbuffer.buffer
        if currentState == sapair.state
            for i in 1:length(sapair.actionSpace)
                if decision == sapair.actionSpace[i]
                    sapair.actionCount[i] += Int64(1)
                    sapair.Q_list[i] = (sapair.Q_list[i] * (sapair.actionCount[i]-1) + newReward) / sapair.actionCount[i]
                end
            end
        end
    end
end

function CompareState(state1::State, state2::State)
    find = true
    for i in 1:nfields(state1)
         if getfield(state1,i) != getfield(state2,i)
             find = false
         end
     end
     return find
end

function AgentDecision(currentState::State, actionSpace::Vector{Action}, initial_Q_list::Vector{Float64}, initial_actionCount::Vector{Int64}, HDCPY::HoldingCompany, progress_index::Float64)
    qbuffer = HDCPY.history.qbuffer
    find = 0
    for sapair in qbuffer.buffer
        if CompareState(currentState, sapair.state)
            find = 1
            decision = findOptAction(sapair, progress_index)
        end
    end
    if find == 0
        push!(qbuffer.buffer, ConfrontNewState(currentState, actionSpace, initial_Q_list,initial_actionCount))
        decision = Action((0,0))
    end

    #println("Find:", find)
    return decision
end
