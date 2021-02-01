using Unitful
using DataStructures

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)*u"rad"

plot(result, "phi", heading="Sine(time)")

println("\n... result info:")
printResultInfo(result)
