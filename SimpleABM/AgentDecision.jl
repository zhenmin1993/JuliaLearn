
function AverageProfit(generator::Generator)
    period = 1

    if length(generator.history.profit_history) < (period+1)
        return sum(generator.history.profit_history)/length(generator.history.profit_history)
    end

    if length(generator.history.profit_history) >= (period+1)
        return sum(generator.history.profit_history[end-period:end-1])/period
    end
end

function AverageProfit(HDCPY::HoldingCompany)
    period = 3

    if length(HDCPY.history.profit_history) < 4
        return sum(HDCPY.history.profit_history)/length(generator.history.profit_history)
    end

    if length(HDCPY.history.profit_history) >= 4
        return sum(HDCPY.history.profit_history[end-period:end-1])
    end
end

##Decision of every generator
function PriceDecision!(generator::Generator)
    average_profit = AverageProfit(generator)
    if generator.history.clear_price_history[end] < generator.offer_price
        generator.offer_price = max(generator.offer_price * 0.9, generator.marginal_cost)
        generator.price_decision = -1
    end

    if generator.history.clear_price_history[end] >= generator.offer_price
        price_gap = generator.history.clear_price_history[end] - generator.offer_price
        if generator.profit < average_profit && abs(generator.profit - average_profit) >1
            generator.offer_price = min(max(generator.offer_price - generator.price_decision * 0.1 * price_gap, generator.marginal_cost),200)
            generator.price_decision = -generator.price_decision
        end
        if generator.profit >= average_profit && abs(generator.profit - average_profit) >1
            generator.offer_price = min(max(generator.offer_price + generator.price_decision * 0.1 * price_gap,generator.marginal_cost),200)
        end

        if  abs(generator.profit - average_profit) <= 1
            this_rand = rand(1)[1]
            if this_rand >= 0.5
                generator.offer_price = min(max(generator.offer_price + 0.2 * price_gap ,generator.marginal_cost),200)
                generator.price_decision = 1
            end
            if this_rand < 0.5
                generator.offer_price = min(max(generator.offer_price - 0.2 * price_gap,generator.marginal_cost),200)
                generator.price_decision = -1
            end
        end
    end


    push!(generator.history.offer_price_history,generator.offer_price)
    push!(generator.history.price_decision_history, generator.price_decision)
end

function PriceDecision!(HDCPY::HoldingCompany)
    average_profit = AverageProfit(HDCPY)
    if HDCPY.history.clear_price_history[end] < generator.offer_price
        generator.offer_price = max(generator.offer_price * 0.9, generator.marginal_cost)
        generator.decision = -1
    end

    if generator.history.clear_price_history[end] >= generator.offer_price
        price_gap = generator.history.clear_price_history[end] - generator.offer_price
        if generator.profit < average_profit
            generator.offer_price = max(generator.offer_price - generator.price_decision * 0.1 * price_gap, generator.marginal_cost)
            generator.price_decision = -generator.price_decision
        end
        if generator.profit >= average_profit
            generator.offer_price = max(generator.offer_price + generator.price_decision * 0.1 * price_gap,generator.marginal_cost)
        end
    end
    return generator.price_decision
end


function QuantityDecision!(generator::Generator)
    average_profit = AverageProfit(generator)

    if generator.profit < average_profit && abs(generator.profit - average_profit) >= 1
        generator.offer_quantity = min(max(generator.offer_quantity *(1 - generator.quantity_decision * 0.1) , generator.g_min) , generator.g_max)
        generator.quantity_decision = -generator.quantity_decision
    end

    if generator.profit >= average_profit && abs(generator.profit - average_profit) >= 1
        generator.offer_quantity = min(max(generator.offer_quantity *(1 + generator.quantity_decision * 0.1) , generator.g_min) , generator.g_max)
    end

    if abs(generator.profit - average_profit) < 1
        this_rand = rand(1)[1]
        if this_rand >= 0.5
            generator.offer_quantity = min(max(generator.offer_quantity *(1 + 1 * 0.2) , generator.g_min) , generator.g_max)
            generator.quantity_decision = 1
        end
        if this_rand < 0.5
            generator.offer_quantity = min(max(generator.offer_quantity *(1 - 1 * 0.2) , generator.g_min) , generator.g_max)
            generator.quantity_decision = -1
        end
    end

    push!(generator.history.offer_quantity_history, generator.offer_quantity)
    push!(generator.history.quantity_decision_history, generator.quantity_decision)

end

function QuantityDecision!(HDCPY::HoldingCompany)
    average_profit = AverageProfit(HDCPY)
    if generator.history.clear_price_history[end] < generator.offer_price
        generator.offer_price = max(generator.offer_price * 0.9, generator.marginal_cost)
        generator.decision = -1
    end

    if generator.history.clear_price_history[end] >= generator.offer_price
        price_gap = generator.history.clear_price_history[end] - generator.offer_price
        if generator.profit < average_profit
            generator.offer_price = max(generator.offer_price - generator.decision * 0.1 * price_gap, generator.marginal_cost)
            generator.decision = -generator.decision
        end
        if generator.profit >= average_profit
            generator.offer_price = max(generator.offer_price + generator.decision * 0.1 * price_gap,generator.marginal_cost)
        end
    end
    return generator.decision
end
