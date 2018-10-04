function PriceLearning!(HDCPY::HoldingCompany, clear_price)
    alpha = 0.6
    previous_price_estimation = HDCPY.history.price_estimation_history[end]
    this_price_estimation = previous_price_estimation*alpha + clear_price*(1-alpha)
    push!(HDCPY.history.price_estimation_history,this_price_estimation)
end
