using JuMP,CPLEX


function OptimizeBidding(company::HoldingCompany)
    g_max = []
    g_min = []
    marginal_cost = []
    demand = []
    VoLL = []
    total_g_num = length(company.generator_portfolio)
    total_consumer_num = length(company.allconsumers)
    for g_num in 1:total_g_num
        push!(g_max, company.generator_portfolio[g_num].g_max)
        push!(g_min, company.generator_portfolio[g_num].g_min)
        push!(marginal_cost, company.generator_portfolio[g_num].marginal_cost)
    end

    for consumer_num in 1:total_consumer_num
        push!(demand,company.allconsumers[consumer_num].demand)
        push!(VoLL, company.allconsumers[consumer_num].VoLL)
    end

    offer = Model(solver = CplexSolver())
    @variable(offer, 0 <= g[i=1:total_g_num] <= g_max[i])
    @variable(offer, u[i=1:total_g_num], Bin)
    @variable(offer, supplied[i=1:total_consumer_num], Bin)
    @variable(offer, bid_price)

    @setObjective(offer, Max, sum((bid_price - marginal_cost[i])*g[i] for i = 1:total_g_num))

    @addConstraint(offer, sum(supplied.*demand) <= sum(u.*g))
    for g_num in 1:total_g_num
        @addConstraint(offer, bid_price >= marginal_cost[g_num] * u[g_num])
    end

    for consumer_num in 1:total_consumer_num
        @addConstraint(offer, bid_price >= VoLL[consumer_num] * (1-supplied[consumer_num]))
    end

    status = solve(offer)
    return status, getvalue(bid_price)

end
