import PyPlot
x = linspace(0, 10, 200)
z = linspace(0, 10, 200)
q = cos.(z)
y = sin.(x)

PyPlot.plot(x, y, "b-", linewidth=2)
PyPlot.plot(z, q, "b-", linewidth=2)
