function solve_ed_inplace(c_w_scale)
    tic()
    obj_out = Float64[]
    w_out = Float64[]
    g1_out = Float64[]
    g2_out = Float64[]

    ed=Model(solver = CplexSolver())

    # Define decision variables
    @defVar(ed, 0 <= g[i=1:2] <= g_max[i]) # power output of generators
    @defVar(ed, 0 <= w  <= w_f ) # wind power injection

    # Define the objective function
    @setObjective(ed,Min,sum{c_g[i] * g[i],i=1:2}+ c_w * w)

    # Define the constraint on the maximum and minimum power output of each generator
    for i in 1:2
        @addConstraint(ed,  g[i] <= g_max[i]) #maximum
        @addConstraint(ed,  g[i] >= g_min[i]) #minimum
    end


    # Define the constraint on the wind power injection
    @addConstraint(ed, w <= w_f)

    # Define the power balance constraint
    @addConstraint(ed, sum{g[i], i=1:2} + w == d)
    solve(ed)

    for c_g1_scale = 1:1:3
        @setObjective(ed, Min, c_g1_scale*c_g[1]*g[1] + c_g[2]*g[2] + c_w_scale*c_w*w)
        solve(ed)
        push!(obj_out,getobjectivevalue(ed))
        push!(w_out,getvalue(w))
        push!(g1_out,getvalue(g[1]))
        push!(g2_out,getvalue(g[2]))
    end
    toc()
    return obj_out, w_out, g1_out, g2_out
end
solve_ed_inplace(2);
