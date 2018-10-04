
include("AgentDecision.jl")
function update!(HDCPY::HoldingCompany, clear_price)
    total_profit = 0
    for generator in HDCPY.generator_portfolio.generators_included
        generator.profit = (clear_price - generator.marginal_cost) * generator.history.real_quantity_history[end]
        total_profit += generator.profit
        push!(generator.history.profit_history, generator.profit)
        push!(generator.history.clear_price_history, clear_price)
    end
    push!(HDCPY.history.profit_history, total_profit)
    push!(HDCPY.history.clear_price_history, clear_price)
end

function update!(consumer::Consumer, clear_price)
end

function ReInitialize(MO::MarketOperator, HDCPY::HoldingCompany)
    return deepcopy(MO),deepcopy(HDCPY)
end


function RunSimulation(MO::MarketOperator, HDCPY::HoldingCompany, total_round)
    for round in 1:total_round
        clear_price = clear(MO)
        update!(HDCPY, clear_price)
        for generator in HDCPY.generator_portfolio.generators_included
            PriceDecision!(generator)
            QuantityDecision!(generator)
            if round > 1 && round % 50==0
                println("The real quantity of generator ", generator.name, "  ",generator.history.real_quantity_history[end])
                println("The offer quantity of generator ", generator.name, "  " ,generator.history.offer_quantity_history[end-1])
                println("The clear price ", generator.name, "  ",generator.history.clear_price_history[end])
                println("The offer price of generator ", generator.name, "  " ,generator.history.offer_price_history[end-1])
            end
        end
        println("This is round: ", round)
        println("This clear price: ",clear_price)
        println("This profit: ",HDCPY.history.profit_history[end])
        if round % 50 == 0 || round == 1
            PlotTrade(MO)
        end
    end
end
