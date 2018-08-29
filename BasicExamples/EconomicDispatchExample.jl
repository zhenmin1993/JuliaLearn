


# In this cell we create  function solve_ed, which solves the economic dispatch problem for a given set of input parameters.
function solve_ed(g_max, g_min, c_g, c_w, d, w_f)
    #Define the economic dispatch (ED) model
    ed=Model(solver = CplexSolver())


    # Define decision variables
    @defVar(ed, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @defVar(ed, 0 <= w  <= w_f ) # wind power injection

    # Define the objective function
    @setObjective(ed,Min,sum{(c_g[i] * g[i]),i=1:2}+ c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    for i in 1:2
        @addConstraint(ed,  g[i] <= g_max[i]) #maximum
        @addConstraint(ed,  g[i] >= g_min[i]) #minimum
    end

    # Define the constraint on the wind power injection
    @addConstraint(ed, w <= w_f)

    # Define the power balance constraint
    @addConstraint(ed, sum{g[i], i=1:2} + w == d)

    # Solve statement
    solve(ed)

    # return the optimal value of the objective function and its minimizers
    return getvalue(g), getvalue(w), w_f-getvalue(w), getobjectivevalue(ed)
end

# Solve the economic dispatch problem
(g_opt,w_opt,ws_opt,obj)=solve_ed(g_max, g_min, c_g, c_w, d, w_f);

println("\n")
println("Dispatch of Generators: ", g_opt[i=1:2], " MW")
println("Dispatch of Wind: ", w_opt, " MW")
println("Wind spillage: ", w_f-w_opt, " MW")
println("\n")
println("Total cost: ", obj, "\$")
