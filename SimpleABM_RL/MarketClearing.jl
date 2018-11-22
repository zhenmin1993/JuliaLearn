mutable struct MarketOperator{T1,T2}
    name::String
    holding_companies::Vector{T1}
    consumers::Vector{T2}
end

function GetAllQuantity(generators)
    all_quantity = []
    for gen in generators
        push!(all_quantity, deepcopy(gen.offer_quantity))
    end
    return all_quantity
end


function kW2MW(power::Float64)
    return power/1000
end

##Market clearing algorithm
function clear(MO::MarketOperator)
    allgenerators,allconsumers = sortbybid!(MO)  #Sort all generators(low->high) and consumers(high->low)
    #println(typeof(allgenerators))
    all_quantity = GetAllQuantity(allgenerators)  #Total quantity that generators claimed
    generator_num = 1 #initialize generator number
    clear_price = 0 #Initiate market price
    residual = 0 #this is a variable indicating the energy gap of one consumer when switching generators
    total_consumed_quantity_this_generator = 0  #this is a variable recoding the exact quantity of energy that has been consumed by one generator
    for consumer_num in 1:length(allconsumers)
        residual = 0
        all_quantity[generator_num] += - kW2MW(allconsumers[consumer_num].demand)
        total_consumed_quantity_this_generator += kW2MW(allconsumers[consumer_num].demand)
        if all_quantity[generator_num] <= 0   #This means the current generator's quantity has been completely consumed
            residual = - all_quantity[generator_num]
            push!(allgenerators[generator_num].history.real_quantity_history, total_consumed_quantity_this_generator - residual)
            generator_num += 1
            if generator_num > length(allgenerators)  #This means all generators' offered quantity are used up
                #clear_price = (allconsumers[consumer_num].VoLL + allgenerators[generator_num-1].offer_price)/2
                clear_price = allconsumers[consumer_num].VoLL
                push!(allgenerators[generator_num-1].history.real_quantity_history, total_consumed_quantity_this_generator - residual)
                break
            end
            println("Now Clean: ",generator_num)
            total_consumed_quantity_this_generator = 0
            all_quantity[generator_num] += -residual
            total_consumed_quantity_this_generator += residual
        end

        #Stop pairing if consumer's VoLL is less than the generator's offered price
        if allconsumers[consumer_num].VoLL <= (allgenerators[generator_num].offer_price)
            if residual > 0
                #clear_price = (allconsumers[consumer_num].VoLL + allgenerators[generator_num-1].offer_price)/2
                clear_price = allconsumers[consumer_num].VoLL
            end

            if residual == 0
                clear_price = allgenerators[generator_num].offer_price
            end
            push!(allgenerators[generator_num].history.real_quantity_history, total_consumed_quantity_this_generator - residual)
            if generator_num < length(allgenerators)
                for gen_unuse_num in generator_num+1:length(allgenerators)
                    push!(allgenerators[gen_unuse_num].history.real_quantity_history, 0)
                end
            end
            break
            #println("good")
            #println(residual)
        end
    end
    return clear_price
end

function GetAllGenerators(HDCPYs::Vector{HoldingCompany})
    allgenerators = Vector{Generator}(0)
    for HDCPY in HDCPYs
        for generator in HDCPY.generator_portfolio.generators_included
            push!(allgenerators, generator)

        end
    end
    println(length(allgenerators))
    return allgenerators
end


function sortbybid!(MO::MarketOperator)
    allgenerators = GetAllGenerators(MO.holding_companies)
    allconsumers = MO.consumers
    #num_of_generator = length(allgenerators)
    #num_of_consumer = length(allconsumers)
    #sorted_generators = [allgenerators[1]]
    #sorted_consumers = [allconsumers[1]]
    sort!(allgenerators, by = x -> x.offer_price)
    sort!(allconsumers, by = x -> x.VoLL, rev=true)
    return allgenerators,allconsumers
end
