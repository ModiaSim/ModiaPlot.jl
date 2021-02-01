using  DataStructures
using  Unitful

t  = range(0.0, stop=10.0, length=100)
t2 = range(0.0, stop=10.0, length=110)

result = OrderedDict{String,Any}()

result["time"] = t*u"s"
result["phi"]  = sin.(t)u"rad"
result["phi2"] = 0.5 * sin.(t)u"rad"
result["w"]    = cos.(t)u"rad/s"
result["w2"]   = 0.6 * cos.(t)u"rad/s"
result["r"]    = [[0.4 * cos(t[i]), 
                   0.5 * sin(t[i]), 
                   0.3 * cos(t[i])] for i in eachindex(t)]*u"m"

result["nothingSignal"]   = nothing
result["emptySignal"]     = Float64[]
result["wrongSizeSignal"] = sin.(t2)u"rad"

println("... Next plots should give warnings:")
plot(result, ("phi", "r", "signalNotDefined"), heading="Plot with warning 1" , figure=1)
plot(result, ("signalNotDefined",
              "nothingSignal",
              "emptySignal",
              "wrongSizeSignal"), 
              heading="Plot with warning 2" , figure=2)

println("\n... result info:")
printResultInfo(result)
