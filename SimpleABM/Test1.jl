using ReinforcementLearning, ReinforcementLearningEnvironmentDiscrete

learner = QLearning()
env = MDP()
stop = ConstantNumberSteps(10^3)
x = RLSetup(learner, env, stop, callbacks = [TotalReward()])
learn!(x)
println(getvalue(x.callbacks[1]))
