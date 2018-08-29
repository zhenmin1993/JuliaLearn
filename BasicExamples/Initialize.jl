# Define the packages
using JuMP,CPLEX # used for mathematical programming
using Interact # used for enabling the slider
using Gadfly # used for plotting




# Define some input data about the test system
# Maximum power output of generators
const g_max = [1000,1000];
# Minimum power output of generators
const g_min = [0,300];
# Incremental cost of generators
const c_g = [50,100];
# Fixed cost of generators
const c_g0 = [1000,0];
# Wind forecast
const w_f = [150,50];
# Incremental cost of wind generators
const c_w = 20;
# Total demand
const d = 1500;
#Transmission constraints
const line_1 = 100
const line_2 = 1000
