using DataStructures
using Unitful
using MonteCarloMeasurements

t = range(0.0, stop=10.0, length=100)
c = ones(size(t,1))

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = [sin(t[i]) ± 0.1*c[i]  for i in eachindex(t)]*u"rad"

plot(result, "phi", MonteCarloAsArea=true, heading="Sine(time) with MonteCarloMeasurements")

println("\n... result info:")
printResultInfo(result)
