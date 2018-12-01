function GetAllNames(generators::Vector{Generator})
    allowners = Vector{String}(0)
    alltechnames = Vector{String}(0)
    for gen in generators
        push!(allowners, gen.owner)
        push!(alltechnames, gen.name)
    end
    return allowners, alltechnames
end


function PlotTrade(operator::MarketOperator, final::Bool, figure_num::Int64, episodeTitle::String)
    allgenerators,allconsumers = sortbybid!(operator)
    allowners, alltechnames = GetAllNames(allgenerators)
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

    PyPlot.figure(figure_num)
    PyPlot.step(cumulative_bid_quantity_all, bid_price_all)
    PyPlot.step(cumulative_offer_quantity_all, offer_price_all, linestyle="-")
    PyPlot.step(cumulative_offer_quantity_all, marginal_cost_all, linestyle=":")
    PyPlot.title(episodeTitle)
    PyPlot.xlabel("Quantity[MWh]")
    PyPlot.ylabel("Price[€/MWh]")
    if final
        PyPlot.figure(figure_num+1)
        PyPlot.step(cumulative_bid_quantity_all, bid_price_all)
        PyPlot.step(cumulative_offer_quantity_all, offer_price_all, linestyle="-")
        PyPlot.step(cumulative_offer_quantity_all, marginal_cost_all, linestyle=":")
        PyPlot.title(episodeTitle)
        PyPlot.xlabel("Quantity[MWh]")
        PyPlot.ylabel("Price[€/MWh]")
        for txt_owner in zip(cumulative_offer_quantity_all, marginal_cost_all, allowners)
            PyPlot.text(x=txt_owner[1]+1, y=txt_owner[2]-1, s=txt_owner[3])
        end

        for txt_tech in zip(cumulative_offer_quantity_all, offer_price_all, alltechnames)
            PyPlot.text(x=txt_tech[1]+1, y=txt_tech[2]+1, s=txt_tech[3])
        end
    end
end
