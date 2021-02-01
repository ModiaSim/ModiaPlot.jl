using Unitful
using DataStructures

t = range(0.0, stop=10.0, length=100)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)u"rad"
result["w"]    = cos.(t)u"rad/s"

plot(result, ("phi", "w"), prefix="Sim 1:", heading="Test reuse")


result["phi"]  = 1.2*sin.(t)u"rad"
result["w"]    = 0.8*cos.(t)u"rad/s"

plot(result, ("phi", "w"), prefix="Sim 2:", reuse=true)

println("\n... result info:")
printResultInfo(result)
