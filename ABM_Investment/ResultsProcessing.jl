import PyPlot

#capacity mix
figure_num = 0
figure_num += 1
PyPlot.figure(figure_num)


date = 1:length(systemHistory.systemCapacityMix)
conventionalPlantsCapacity = Vector{Float64}(0)
renewablePlantsCapacity = Vector{Float64}(0)
conventionalPlantsNumbers = Vector{Float64}(0)
renewablePlantsNumbers = Vector{Float64}(0)
for year in date
    thisConventionalPlantsCapacity = 0
    thisRenewablePlantsCapacity = 0
    thisConventionalPlantsNumber = 0
    thisRenewablePlantsNumber = 0
    for generator in systemHistory.systemCapacityMix[year]
        if typeof(generator) == ConventionalPlants
            thisConventionalPlantsNumber += 1
            thisConventionalPlantsCapacity += generator.designProperties.maxCapacity
        end

        if typeof(generator) == RenewablePlants
            thisRenewablePlantsNumber += 1
            thisRenewablePlantsCapacity += generator.designProperties.maxCapacity
        end
    end
    push!(conventionalPlantsCapacity,thisConventionalPlantsCapacity)
    push!(renewablePlantsCapacity,thisRenewablePlantsCapacity)
    push!(conventionalPlantsNumbers,thisConventionalPlantsNumber)
    push!(renewablePlantsNumbers,thisRenewablePlantsNumber)
end
println(conventionalPlantsNumbers)
println(renewablePlantsNumbers)

PyPlot.stackplot(date,conventionalPlantsCapacity,renewablePlantsCapacity, colors = ["orange", "green"])
PyPlot.xlabel("time")
PyPlot.ylabel("capacity mix")

PyPlot.plot([],[],color="orange", label="thermal", lineWidth=5)
PyPlot.plot([],[],color="green",label="renewable", lineWidth=5)
PyPlot.legend()


#plt.show()
