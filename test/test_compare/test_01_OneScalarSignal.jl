module test_01_OneScalarSignal

using ModiaPlot
using DataStructures
using DataFrames

t1 = range(0.0, stop=10.0, length=100)
t2 = deepcopy(t1)
t3 = range(0.0 , stop=10.0 , length=112)
t4 = range(-0.1, stop=10.1, length=111)

result1 = OrderedDict{String,Any}()
result2 = DataFrame()
result3 = DataFrame()
result4 = DataFrame()

result1["time"]   = t1
result1["phi"]    = sin.(t1)

result2."time"    = t2
result2."phi"     = sin.(t2)

result3[!,"time"] = t3
result3[!,"phi"]  = sin.(t3)

result4."time"    = t4
result4."phi"     = sin.(t4.+0.01)

plot(result1, "phi", prefix="r1.")
plot(result2, "phi", prefix="r2.", reuse=true)
plot(result3, "phi", prefix="r3.", reuse=true)
plot(result4, "phi", prefix="r4.", reuse=true)

# Check makeSameTimeAxis
(result1b, result2b, sameTimeRange1) = makeSameTimeAxis(result1, result2, names=["phi", "w"])
println("sameTimeRange1 = ", sameTimeRange1)
plot(result1b, "phi", prefix="r1b.", reuse=true)
plot(result2b, "phi", prefix="r2b.", reuse=true)

(result1c, result3b, sameTimeRange3) = makeSameTimeAxis(result1, result3)
println("sameTimeRange3 = ", sameTimeRange3)
plot(result1c, "phi", prefix="r1c.", reuse=true)
plot(result3b, "phi", prefix="r3b.", reuse=true)

(result1d, result4b, sameTimeRange4) = makeSameTimeAxis(result1, result4)
println("sameTimeRange4 = ", sameTimeRange4)
plot(result1d, "phi", prefix="r1d.", reuse=true)
plot(result4b, "phi", prefix="r4b.", reuse=true)

# check compareResults
(success2, diff2, diff_names2, max_error2, within_tolerance2) = compareResults(result1, result2)
println("success2 = $success2, max_error2 = $max_error2, within_tolerance2 = $within_tolerance2")
plot(diff2, "phi", prefix="diff2_", figure=2)

(success3, diff3, diff_names3, max_error3, within_tolerance3) = compareResults(result1, result3)
plot(diff3, "phi", prefix="diff3_", figure=2, reuse=true)
println("success3 = $success3, max_error3 = $max_error3, within_tolerance3 = $within_tolerance3")

(success4, diff4, diff_names4, max_error4, within_tolerance4) = compareResults(result1, result4)
plot(diff4, "phi", prefix="diff4_", figure=2, reuse=true)
println("success4 = $success4, max_error4 = $max_error4, within_tolerance4 = $within_tolerance4")
end
