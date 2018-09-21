import PyPlot


#x = linspace(1, 10, 50)
#y0 = sin.(x)
#y = y0 + 2.5
x=[0,1,2,3]
y=[3,2,1,0]

PyPlot.step(x, y)

#y = ma.masked_where((y0 > -0.15) & (y0 < 0.15), y - 0.5)
#plt.step(x, y, label='masked (pre)')

#PyPlot.legend()

PyPlot.xlim(-1, 15)
PyPlot.ylim(-0.5, 4)

#plt.show()
