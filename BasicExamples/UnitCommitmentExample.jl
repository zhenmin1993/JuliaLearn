# In this cell we introduce binary decision u to the economic dispatch problem (function solve_ed)
function solve_uc(g_max, g_min, c_g, w_f, c_w, d)
    #Define the unit commitment (UC) model
    uc=Model(solver = CplexSolver())

    # Define decision variables
    @defVar(uc, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @defVar(uc, u[i=1:2], Bin) # Binary status of generators
    @defVar(uc, 0 <= w[i=1:2]  <= w_f[i] ) # wind power injection

    # Define the objective function
    @setObjective(uc,Min,sum(c_g[i] * g[i] * u[i]+ c_w * w[i] for i=1:2))

    # Define the constraint on the maximum and minimum power output of each generator
    for i in 1:2
        @addConstraint(uc,  g[i] <= g_max[i] * u[i]) #maximum
        @addConstraint(uc,  g[i] >= g_min[i] * u[i]) #minimum
        @addConstraint(uc, w[i] <= w_f[i]) # Wind power limits
        @addConstraint(uc,  w[1] <= line_1) #transmission line 1
        @addConstraint(uc,  g[1]+w[1]+w[2] <= line_2)
    end

    # Define the constraint on the wind power injection
    #@addConstraint(uc, w <= w_f)

    # Define the power balance constraint
    @addConstraint(uc, sum(g[i]+w[i] for i=1:2) == d)

    # Solve statement
    status = solve(uc)

    return status, getvalue(g), getvalue(w), w_f-getvalue(w), getvalue(u), getobjectivevalue(uc)
end

# Solve the economic dispatch problem
status,g_opt,w_opt,ws_opt,u_opt,obj=solve_uc(g_max, g_min, c_g, w_f,c_w, d);


println("\n")
println("Dispatch of Generators: ", g_opt[:], " MW")
println("Commitments of Generators: ", u_opt[:])
println("Dispatch of Wind: ", w_opt[:], " MW")
println("Wind spillage: ", w_f-w_opt, " MW")
println("\n")
println("Total cost: ", obj, "\$")
