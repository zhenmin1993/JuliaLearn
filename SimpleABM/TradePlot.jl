function PlotTrade(operator::MarketOperator)
    allgenerators,allconsumers = sortbybid(operator)
    offer_price_all = [allgenerators[1].offer_price]
    cumulative_offer_amount_all = [0.0]
    bid_price_all = [allconsumers[1].VoLL]
    cumulative_bid_amount_all = [0.0]
    for consumer_num in 1:length(allconsumers)
        push!(bid_price_all, allconsumers[consumer_num].VoLL)
        push!(cumulative_bid_amount_all, allconsumers[consumer_num].demand/1000 + cumulative_bid_amount_all[end,])
    end

    for generator_num in 1:length(allgenerators)
        push!(offer_price_all, allgenerators[generator_num].offer_price)
        push!(cumulative_offer_amount_all, allgenerators[generator_num].offer_amount + cumulative_offer_amount_all[end,])
    end

    PyPlot.step(cumulative_bid_amount_all, bid_price_all)
    PyPlot.step(cumulative_offer_amount_all, offer_price_all)
end
