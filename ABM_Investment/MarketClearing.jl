
function GetAllQuantity(generators)
    allQuantity = Vector{Real}(0)
    for gen in generators
        push!(allQuantity, deepcopy(gen.offerQuantity))
    end
    return allQuantity
end


function kW2MW(power::Float64)
    return power/1000
end

function MatchPowerFlow(technology::Technology, allPowerFlows::Vector{PowerFlow})
    find = 0
    for powerFlow in allPowerFlows
        if powerFlow.from == technology
            #println(powerFlow)
            #println("total flow nums: ",length(allPowerFlows))
            #find = 1
            #println(find)
            return powerFlow
        end
    end
end

function MatchOwnership(technology::Technology, allOwnerShips::Vector{GenCoOwnership})
    for ownership in allOwnerShips
        if technology == ownership.to
            #println(allOwnerShips)
            return ownership
        end
    end
end

function Payment(allPowerFlows::Vector{PowerFlow}, allOwnerShips::Vector{GenCoOwnership})
    for powerflow in allPowerFlows
        thisTechnology = powerflow.from
        #println(allOwnerShips)
        beneficialAgent = MatchOwnership(thisTechnology, allOwnerShips).from
        beneficialAgent.financialCondition.dailyProfit += (powerflow.marketPrice - thisTechnology.economicProperties.variableCost) * powerflow.quantity
    end
end

##Market clearing algorithm
function Clear(allGenerators::Vector{Technology}, allConsumers::Vector{Consumer}, allPowerFlows::Vector{PowerFlow})
    allGenerators = sortbybid!(allGenerators)
    #println("total generators: ",length(allGenerators))
    allConsumers = sortbybid!(allConsumers)  #Sort all generators(low->high) and consumers(high->low)
    #println(typeof(allgenerators))
    all_quantity = GetAllQuantity(allGenerators)  #Total quantity that generators claimed
    generator_num = 1 #initialize generator number
    clear_price = 0 #Initiate market price
    residual = 0 #this is a variable indicating the energy gap of one consumer when switching generators
    total_consumed_quantity_this_generator = 0  #this is a variable recoding the exact quantity of energy that has been consumed by one generator
    for consumer_num in 1:length(allConsumers)
        residual = 0
        all_quantity[generator_num] += - kW2MW(allConsumers[consumer_num].demand)
        total_consumed_quantity_this_generator += kW2MW(allConsumers[consumer_num].demand)
        if all_quantity[generator_num] <= 0   #This means the current generator's quantity has been completely consumed
            residual = - all_quantity[generator_num]
            thisPowerFlow = MatchPowerFlow(allGenerators[generator_num], allPowerFlows)
            thisPowerFlow.quantity = total_consumed_quantity_this_generator - residual
            #push!(allGenerators[generator_num].history.real_quantity_history, total_consumed_quantity_this_generator - residual)
            generator_num += 1
            if generator_num > length(allGenerators)  #This means all generators' offered quantity are used up
                #clear_price = (allconsumers[consumer_num].VoLL + allgenerators[generator_num-1].offer_price)/2
                clear_price = allConsumers[consumer_num].VoLL
                #push!(allGenerators[generator_num-1].history.real_quantity_history, total_consumed_quantity_this_generator - residual)
                break
            end
            #println("Now Clean: ",generator_num)
            total_consumed_quantity_this_generator = 0
            all_quantity[generator_num] += -residual
            total_consumed_quantity_this_generator += residual
        end

        #Stop pairing if consumer's VoLL is less than the generator's offered price
        if allConsumers[consumer_num].VoLL <= (allGenerators[generator_num].offerPrice)
            if residual > 0
                #clear_price = (allconsumers[consumer_num].VoLL + allgenerators[generator_num-1].offer_price)/2
                clear_price = allConsumers[consumer_num].VoLL
            end

            if residual == 0
                clear_price = allGenerators[generator_num].offerPrice
            end
            thisPowerFlow = MatchPowerFlow(allGenerators[generator_num], allPowerFlows)
            thisPowerFlow.quantity = total_consumed_quantity_this_generator - residual
            #push!(allGenerators[generator_num].history.real_quantity_history, total_consumed_quantity_this_generator - residual)
            if generator_num < length(allGenerators)
                for gen_unuse_num in generator_num+1:length(allGenerators)
                    thisPowerFlow = MatchPowerFlow(allGenerators[gen_unuse_num], allPowerFlows)
                    thisPowerFlow.quantity = 0
                    #push!(allGenerators[gen_unuse_num].history.real_quantity_history, 0)
                end
            end
            break
            #println("good")
            #println(residual)
        end
    end
    for powerflow in allPowerFlows
        powerflow.marketPrice = clear_price
    end

    #return clear_price
end

function GetAllGenerators(MO::MarketOperator)
    allGenerators = Vector{Generator}(0)
    for HDCPY in MO.holding_companies
        for generator in HDCPY.technologies
            push!(allGenerators, generator)

        end
    end
    println(length(allGenerators))
    return allGenerators
end


function sortbybid!(allGenerators::Vector{Technology})
    sort!(allGenerators, by = x -> x.offerPrice)
    return allGenerators
end

function sortbybid!(allConsumers::Vector{Consumer})
    sort!(allConsumers, by = x -> x.VoLL, rev=true)
    return allConsumers
end
