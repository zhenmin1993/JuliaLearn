mutable struct MarketOperator{T1,T2}
    name::String
    generators::Vector{T1}
    consumers::Vector{T2}
end


function clear(operator::MarketOperator)
    allgenerators,allconsumers = sortbybid(operator)
    generator_num = 1
    clear_price = 0
    residual = 0
    for consumer_num in 1:length(allconsumers)
        residual = 0
        allgenerators[generator_num].offer_amount += -allconsumers[consumer_num].demand / 1000
        if allgenerators[generator_num].offer_amount <= 0
            residual = - allgenerators[generator_num].offer_amount
            generator_num += 1
            allgenerators[generator_num].offer_amount += -residual / 1000
        end
        if allconsumers[consumer_num].VoLL <= (allgenerators[generator_num].offer_price)
            if residual > 0
                clear_price = (allconsumers[consumer_num].VoLL + allgenerators[generator_num-1].offer_price)/2
            end

            if residual == 0
                clear_price = allgenerators[generator_num].offer_price
            end
            println("good")
            println(residual)

            #print(clear_price)
            return clear_price

        end
    end
end

function sortbybid(operator::MarketOperator)
    allgenerators = deepcopy(operator.generators)
    allconsumers = deepcopy(operator.consumers)
    num_of_generator = length(allgenerators)
    num_of_consumer = length(allconsumers)
    sorted_generators = [allgenerators[1]]
    sorted_consumers = [allconsumers[1]]
    sort!(allgenerators, by = x -> x.offer_price)
    sort!(allconsumers, by = x -> x.VoLL, rev=true)
    return allgenerators,allconsumers
end
