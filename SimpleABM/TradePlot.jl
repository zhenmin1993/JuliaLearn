function PlotTrade(operator::MarketOperator)
    allgenerators,allconsumers = sortbybid!(operator)
    offer_price_all = [allgenerators[1].offer_price]
    marginal_cost_all = [allgenerators[1].marginal_cost]
    cumulative_offer_quantity_all = [0.0]
    bid_price_all = [allconsumers[1].VoLL]
    cumulative_bid_quantity_all = [0.0]
    for consumer_num in 1:length(allconsumers)
        push!(bid_price_all, allconsumers[consumer_num].VoLL)
        push!(cumulative_bid_quantity_all, allconsumers[consumer_num].demand/1000 + cumulative_bid_quantity_all[end,])
    end

    for generator_num in 1:length(allgenerators)
        push!(offer_price_all, allgenerators[generator_num].offer_price)
        push!(marginal_cost_all, allgenerators[generator_num].marginal_cost)
        push!(cumulative_offer_quantity_all, allgenerators[generator_num].offer_quantity + cumulative_offer_quantity_all[end,])
    end
    push!(offer_price_all, 200.0)
    push!(cumulative_offer_quantity_all, cumulative_offer_quantity_all[end,])
    push!(marginal_cost_all, allgenerators[end].marginal_cost)

    PyPlot.figure(1)
    PyPlot.step(cumulative_bid_quantity_all, bid_price_all)
    PyPlot.step(cumulative_offer_quantity_all, offer_price_all, linestyle="-")
    PyPlot.step(cumulative_offer_quantity_all, marginal_cost_all, linestyle=":")
end
