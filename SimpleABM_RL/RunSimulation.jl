
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

function ReInitialize(HDCPYs)
    for HDCPY in HDCPYs
        for generator in HDCPY.generator_portfolio.generators_included
            generator.offer_price = generator.marginal_cost
            generator.offer_quantity = generator.g_max
        end
    end
end


function ExplorationSimulation(MO::MarketOperator, HDCPYs, total_exploration_episodes)
    for episode in 1:total_exploration_episodes
        progress_index = 1.0

        clear_price = clear(MO)

        for HDCPY in HDCPYs
            update!(HDCPY, clear_price)
            updateQBuffer!(HDCPY.previous_state, HDCPY.decision, HDCPY.history.qbuffer, round(HDCPY.history.profit_history[end]),episode)
            for generator_num in 1:HDCPY.generator_portfolio.total_generator_num
                this_generator = HDCPY.generator_portfolio.generators_included[generator_num]
                this_offer_price = this_generator.offer_price
                this_offer_quantity = this_generator.offer_quantity
                agentPosition = JudgePosition(this_offer_price, clear_price)
                thisState = State(Int8(agentPosition), this_offer_price, this_offer_quantity,round(clear_price), round(this_generator.profit))
                HDCPY.previous_state = thisState
                decision = AgentDecision(thisState, actionSpace, initial_Q_list, initial_actionCount, HDCPY, progress_index)
                if this_generator.marginal_cost < clear_price && this_generator.profit == 0
                    quantity_decision = deepcopy(decision.action[2])
                    decision = Action((-1, quantity_decision))
                end
                HDCPY.decision = decision

                AgentExecute!(HDCPY)


                if episode > 1 && episode % 50==0
                    println(decision)
                    println("The real quantity of generator ", this_generator.name, "  ",this_generator.history.real_quantity_history[end])
                    println("The offer quantity of generator ", this_generator.name, "  " ,this_generator.history.offer_quantity_history[end-1])
                    println("The clear price ", this_generator.name, "  ",this_generator.history.clear_price_history[end])
                    #println("The offer price of generator ", this_generator.name, "  " ,this_generator.history.offer_price_history[end-1])
                end
            end
        end
        println("This is round: ", episode)
        println("This clear price: ",clear_price)
        #println("This profit: ",HDCPY.history.profit_history[end])
        if episode % 111 == 0 || episode == 1 || episode == total_exploration_episodes
        #if round <= 20
            PlotTrade(MO,episode == total_exploration_episodes,1, "Exploration")
        end
    end
end

function RealSimulation(MO::MarketOperator, HDCPYs, total_episodes, total_exploration_episodes)
    ReInitialize(HDCPYs)
    for episode in 1:total_episodes
        progress_index = 1 - (episode)/(total_episodes)

        clear_price = clear(MO)

        for HDCPY in HDCPYs
            update!(HDCPY, clear_price)
            updateQBuffer!(HDCPY.previous_state, HDCPY.decision, HDCPY.history.qbuffer, round(HDCPY.history.profit_history[end]),episode)
            for generator_num in 1:HDCPY.generator_portfolio.total_generator_num
                this_generator = HDCPY.generator_portfolio.generators_included[generator_num]
                this_offer_price = this_generator.offer_price
                this_offer_quantity = this_generator.offer_quantity
                agentPosition = JudgePosition(this_offer_price, clear_price)
                thisState = State(Int8(agentPosition), this_offer_price, this_offer_quantity,round(clear_price), round(this_generator.profit))
                HDCPY.previous_state = thisState
                decision = AgentDecision(thisState, actionSpace, initial_Q_list, initial_actionCount, HDCPY, progress_index)
                if this_generator.marginal_cost < clear_price && this_generator.profit == 0
                    quantity_decision = deepcopy(decision.action[2])
                    decision = Action((-1, quantity_decision))
                end
                HDCPY.decision = decision

                AgentExecute!(HDCPY)


                if episode > 1 && episode % 50==0
                    println(decision)
                    println("The real quantity of generator ", this_generator.name, "  ",this_generator.history.real_quantity_history[end])
                    println("The offer quantity of generator ", this_generator.name, "  " ,this_generator.history.offer_quantity_history[end-1])
                    println("The clear price ", this_generator.name, "  ",this_generator.history.clear_price_history[end])
                    #println("The offer price of generator ", this_generator.name, "  " ,this_generator.history.offer_price_history[end-1])
                end
            end
        end
        println("This is round: ", episode)
        println("This clear price: ",clear_price)
        #println("This profit: ",HDCPY.history.profit_history[end])
        if episode % 111 == 0 || episode == 1 || episode == total_episodes
        #if round <= 20
            PlotTrade(MO,episode == total_episodes, 3, "Learning")
        end
    end
    figure = 5
    PyPlot.figure(figure)
    for gen_num in 1:length(HDCPYs)
        PyPlot.subplot(5,3,gen_num)
        PyPlot.plot(HDCPYs[gen_num].history.profit_history[total_exploration_episodes:end])
        PyPlot.xlabel("Iteration")
        PyPlot.ylabel("Profit[€]")
        PyPlot.title(string(HDCPYs[gen_num].name, " Profit history"))
    end


    figure += 1
    PyPlot.figure(figure)
    for gen_num in 1:length(HDCPYs)
        PyPlot.subplot(5,3,gen_num)
        PyPlot.plot(HDCPYs[gen_num].history.decision_history[total_exploration_episodes:end])
        PyPlot.xlabel("Iteration")
        PyPlot.ylabel("Decision[binary]")
    end


    figure += 1
    PyPlot.figure(figure)
    PyPlot.subplot(1,1,1)
    PyPlot.plot(HDCPYs[1].generator_portfolio.generators_included[1].history.clear_price_history[total_exploration_episodes:end])
    PyPlot.ylabel("Price[€/MWh]")
    PyPlot.xlabel("Iterations")


end
