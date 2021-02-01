using Unitful
using DataStructures

t = range(0.0, stop=10.0, length=100)

const MyResult = OrderedDict{String,Tuple{Bool,Any}}  # value = (isConstant, signal)
ModiaPlot.getRawSignal(result::MyResult, name) = result[name]


result = MyResult()

result["time"]     = (false, t*u"s")
result["phi_max"]  = (true , 1.1f0*u"rad")
result["i_max"]    = (true , 2)
result["open"]     = (true , true)
result["Inertia"]  = (true , [1.1  1.2  1.3;
                              2.1  2.2  2.3;
                              3.1  3.2  3.3]u"kg*m^2")

plot(result, ["phi_max", "i_max", "open", "Inertia[2,2]", "Inertia[1,2:3]", "Inertia"], heading="Constants")

println("\n... result info:")
printResultInfo(result)
