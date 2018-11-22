using JuMP,CPLEX


function OptimizeBidding(company::HoldingCompany, consumerGroup::ConsumerGroup)
    #g_max = []
    #g_min = []
    #marginal_cost = []
    total_demand = consumerGroup.total_consumption
    price_cap = consumerGroup.price_cap

    #total_g_num = length(company.generator_portfolio.generators_included)

    g_max = company.generator_portfolio.generators_included[1].g_max
    g_min = company.generator_portfolio.generators_included[1].g_min
    marginal_cost = company.generator_portfolio.generators_included[1].marginal_cost




    offer = Model(solver = CplexSolver())
    @variable(offer, g_min<= quantity<=g_max)
    #@variable(offer, clear_price)

    @setObjective(offer, Max, (price_cap - price_cap/total_demand * quantity - marginal_cost)*quantity)

    #for g_num in 1:total_g_num
        #@addConstraint(offer, clear_price >= marginal_cost[g_num] * u[g_num])
    #end
    #@addConstraint(offer, clear_price == price_cap - price_cap/total_demand * quantity)
    @addConstraint(offer, quantity <= g_max)
    @addConstraint(offer, quantity >= g_min)


    status = solve(offer)
    optimal_quantity = getvalue(quantity)
    optimal_price = price_cap - price_cap/total_demand * optimal_quantity
    return status, optimal_quantity,optimal_price
end
