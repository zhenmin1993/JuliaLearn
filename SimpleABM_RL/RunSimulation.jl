
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


function RunSimulation(MO::MarketOperator, HDCPYs, total_round)
    for round in 1:total_round
        progress_index = 1 - round/total_round
        clear_price = clear(MO)
        for HDCPY in HDCPYs
            update!(HDCPY, clear_price)
            #PriceDecision!(HDCPY,progress_index)
            QuantityDecision!(HDCPY,progress_index)
            for generator_num in HDCPY.generator_portfolio.total_generator_num:1
                this_generator = HDCPY.generator_portfolio.generators_included[generator_num]


                if round > 1 && round % 50==0
                    println("The real quantity of generator ", this_generator.name, "  ",this_generator.history.real_quantity_history[end])
                    println("The offer quantity of generator ", this_generator.name, "  " ,this_generator.history.offer_quantity_history[end-1])
                    println("The clear price ", this_generator.name, "  ",this_generator.history.clear_price_history[end])
                    #println("The offer price of generator ", this_generator.name, "  " ,this_generator.history.offer_price_history[end-1])
                end
            end
        end
        println("This is round: ", round)
        println("This clear price: ",clear_price)
        #println("This profit: ",HDCPY.history.profit_history[end])
        if round % 111 == 0 || round == 1 || round == total_round
        #if round <= 20
            PlotTrade(MO,round == total_round)
        end
    end
    figure = 3
    PyPlot.figure(figure)
    for gen_num in 1:length(HDCPYs)
        PyPlot.subplot(5,3,gen_num)
        PyPlot.plot(HDCPYs[gen_num].history.profit_history)
        PyPlot.xlabel("Iteration")
        PyPlot.ylabel("Profit[€]")
        PyPlot.title(string(HDCPYs[gen_num].name, " Profit history"))
    end


    figure += 1
    PyPlot.figure(figure)
    for gen_num in 1:length(HDCPYs)
        PyPlot.subplot(5,3,gen_num)
        PyPlot.plot(HDCPYs[gen_num].history.quantity_decision_history)
        PyPlot.xlabel("Iteration")
        PyPlot.ylabel("Decision[binary]")
    end


    figure += 1
    PyPlot.figure(figure)
    PyPlot.subplot(1,1,1)
    PyPlot.plot(HDCPYs[1].generator_portfolio.generators_included[1].history.clear_price_history)
    PyPlot.xlabel("Price[€/MWh]")
    PyPlot.ylabel("Iterations")


end
