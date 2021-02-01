using Unitful
using DataStructures

t = range(0.0, stop=1.0, length=100)

result = OrderedDict{String,Any}()

Ibase  = [1.1  1.2  1.3;
          2.1  2.2  2.3;
          3.1  3.2  3.3]u"kg*m^2"

result["time"]     = t*u"s"
result["Inertia"]  = [Ibase*t[i] for i in eachindex(t)]

plot(result, ["Inertia[2,2]", "Inertia[2:3,3]"], heading="Array signals")

println("\n... result info:")
printResultInfo(result)
