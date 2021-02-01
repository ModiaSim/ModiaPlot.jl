using DataStructures
using Unitful
using MonteCarloMeasurements
using Distributions


t = range(0.0, stop=10.0, length=100)
uniform1(xmin,xmax) = MonteCarloMeasurements.Particles(      100,Distributions.Uniform(xmin,xmax))
uniform2(xmin,xmax) = MonteCarloMeasurements.StaticParticles(100,Distributions.Uniform(xmin,xmax))
particles1 = uniform1(-0.4, 0.4)
particles2 = uniform2(-0.4, 0.4)
result = OrderedDict{String,Any}()

# ∓ are 100 StaticParticles uniform distribution

result["time"] = t*u"s"
result["phi1"] = [sin(t[i]) + particles1*t[i]/10.0 for i in eachindex(t)]*u"rad"
result["phi2"] = [sin(t[i]) + particles2*t[i]/10.0 for i in eachindex(t)]*u"rad"
result["phi3"] = [sin(t[i]) ∓ 0.4*t[i]/10.0        for i in eachindex(t)]*u"rad"

plot(result, ["phi1", "phi2", "phi3"], figure=1,
     heading="Sine(time) with MonteCarloParticles/StaticParticles (plot area)")
     
plot(result, ["phi1", "phi2", "phi3"], MonteCarloAsArea=false, figure=2,
     heading="Sine(time) with MonteCarloParticles/StaticParticles (plot all runs)")

println("\n... result info:")
printResultInfo(result)

