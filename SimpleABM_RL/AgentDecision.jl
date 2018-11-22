
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
    period = 1

    if length(HDCPY.history.profit_history) < (period+1)
        return sum(HDCPY.history.profit_history)/length(HDCPY.history.profit_history)
    end

    if length(HDCPY.history.profit_history) >= (period+1)
        return sum(HDCPY.history.profit_history[end-period:end-1])/period
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

function FindMaxOfferPrice(HDCPY::HoldingCompany)
    max_price = 0
    for generator in HDCPY.generator_portfolio.generators_included
        if generator.offer_price > max_price
            max_price = generator.offer_price
        end
    end
    return max_price
end

function FindMinOfferPrice(HDCPY::HoldingCompany)
    min_price = Inf
    for generator in HDCPY.generator_portfolio.generators_included
        if generator.offer_price < min_price
            min_price = generator.offer_price
        end
    end
    return min_price
end

function SortByMarginalCost!(HDCPY::HoldingCompany)
    sort!(HDCPY.generator_portfolio.generators_included, by = x -> x.marginal_cost)
end


function PriceChange!(HDCPY::HoldingCompany,progress_index::Float64)
    decision = HDCPY.price_decision
    #historical_max_profit_gap = abs(maximum(HDCPY.history.profit_history) - HDCPY.history.profit_history[end])/maximum(HDCPY.history.profit_history) + 0.05 * progress_index
    historical_max_profit_gap = 0.2
    total_gen_num = HDCPY.generator_portfolio.total_generator_num
    for generator_num in reverse(1:total_gen_num)
        this_generator = HDCPY.generator_portfolio.generators_included[generator_num]
        next_generator = HDCPY.generator_portfolio.generators_included[generator_num + 1]
        this_generator.offer_price = min(max(this_generator.offer_price + (0 + decision * historical_max_profit_gap) * this_generator.marginal_cost, this_generator.marginal_cost), next_generator.offer_price)
        push!(this_generator.history.offer_price_history,this_generator.offer_price)
        push!(this_generator.history.price_decision_history, decision)
    end
end



function PriceDecision!(HDCPY::HoldingCompany,progress_index::Float64)
    sort!(HDCPY.generator_portfolio.generators_included, by = x -> x.marginal_cost)
    average_profit = AverageProfit(HDCPY)
    if HDCPY.history.clear_price_history[end] < FindMinOfferPrice(HDCPY)
        HDCPY.price_decision = -1
        PriceChange!(HDCPY,progress_index)

    end

    if HDCPY.history.clear_price_history[end] > FindMaxOfferPrice(HDCPY)
        HDCPY.price_decision = 1
        PriceChange!(HDCPY,progress_index)
    end


    if HDCPY.history.clear_price_history[end] >= FindMinOfferPrice(HDCPY) && HDCPY.history.clear_price_history[end] <= FindMaxOfferPrice(HDCPY)
        if HDCPY.history.profit_history[end] < average_profit && abs(HDCPY.history.profit_history[end] - average_profit) > 0
            HDCPY.price_decision = -HDCPY.price_decision
            PriceChange!(HDCPY,progress_index)

        end
        if HDCPY.history.profit_history[end] >= average_profit && abs(HDCPY.history.profit_history[end] - average_profit) > 0
            PriceChange!(HDCPY,progress_index)
        end

        if  abs(HDCPY.history.profit_history[end] - average_profit) <= 0
            this_rand = rand(1)[1]
            if this_rand >= 0.5
                HDCPY.price_decision = 1
                PriceChange!(HDCPY,progress_index)
            end
            if this_rand < 0.5
                HDCPY.price_decision = -1
                PriceChange!(HDCPY,progress_index)
            end
        end
    end
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

function QuantityChange!(HDCPY::HoldingCompany, progress_index::Float64)
    decision = HDCPY.quantity_decision
    #historical_max_profit_gap = abs(maximum(HDCPY.history.profit_history) - HDCPY.history.profit_history[end])/maximum(HDCPY.history.profit_history) + 0.05 * progress_index
    historical_max_profit_gap = 0.3 * progress_index
    total_gen_num = HDCPY.generator_portfolio.total_generator_num
    for generator_num in reverse(1:total_gen_num)
        this_generator = HDCPY.generator_portfolio.generators_included[generator_num]
        next_generator = HDCPY.generator_portfolio.generators_included[generator_num + 1]
        this_generator.offer_quantity = max(min(this_generator.offer_quantity + (0 + decision * historical_max_profit_gap) * this_generator.offer_quantity, this_generator.g_max), this_generator.g_min)
        push!(this_generator.history.offer_quantity_history,this_generator.offer_quantity)
        push!(this_generator.history.quantity_decision_history, decision)
    end
end

function QuantityDecision!(HDCPY::HoldingCompany, progress_index::Float64)
    sort!(HDCPY.generator_portfolio.generators_included, by = x -> x.marginal_cost)
    average_profit = AverageProfit(HDCPY)

    if HDCPY.history.profit_history[end] < average_profit && abs(HDCPY.history.profit_history[end] - average_profit) > 10
        HDCPY.quantity_decision = -HDCPY.quantity_decision
        QuantityChange!(HDCPY,progress_index)

    end
    if HDCPY.history.profit_history[end] >= average_profit && abs(HDCPY.history.profit_history[end] - average_profit) > 10
        QuantityChange!(HDCPY,progress_index)
    end

    if  abs(HDCPY.history.profit_history[end] - average_profit) <= 10
        this_rand = rand(1)[1]
        if this_rand >= 0.9
            HDCPY.quantity_decision = 1
            QuantityChange!(HDCPY,progress_index)
        end
        if this_rand < 0.1
            HDCPY.quantity_decision = -1
            QuantityChange!(HDCPY,progress_index)
        end
    end
end
