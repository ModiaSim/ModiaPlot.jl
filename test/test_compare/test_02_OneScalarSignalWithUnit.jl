module test_02_OneScalarSignalWithUnit

using ModiaPlot
using Unitful
using DataFrames

t = range(0.0, stop=10.0, length=100)

result1 = DataFrame()
result2 = DataFrame()
result3 = DataFrame()

result1."time" = t*u"s"
result1."w"    = sin.(t)*u"rad/s"

result2."time" = t*u"s"
result2."w"    = 0.0005*u"rad/s" .+ sin.(t)*u"rad/s"

result3."time" = t
result3."w"    = sin.(t.+0.001)

plot(result1, "w", prefix="r1.")
plot(result2, "w", prefix="r2.", reuse=true)
plot(result3, "w", prefix="r3.", reuse=true)

(success2, diff2, diff_names2, max_error2, within_tolerance2) = compareResults(result1, result2)
println("success2 = $success2, max_error2 = $max_error2, within_tolerance2 = $within_tolerance2")
plot(diff2, "w", prefix="diff2_", figure=2)

(success3, diff3, diff_names3, max_error3, within_tolerance3) = compareResults(result1, result3)
println("success3 = $success3, max_error3 = $max_error3, within_tolerance3 = $within_tolerance3")
plot(diff3, "w", prefix="diff3_", figure=2, reuse=true)

end