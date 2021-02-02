# License for this file: MIT (expat)
# Copyright 2021, DLR Institute of System Dynamics and Control
#
# This file is part of module ModiaPlot



###################################################################################
#
# Generic definitions that might be specialized from special result data structures
#
###################################################################################


"""
    hasSignal(result, name)
    
Returns `true` if signal `name` is available in `result`.
"""
hasSignal(result, name) = haskey(result, name)


"""
    (isConstant, signal) = getRawSignal(result, name)
    
Returns result time series `signal` of `name` (an error is raised, if `name` is not known).

If `isConstant=false`, then `signal[i]` is the `value` of the signal at time instant `i`.

If `isConstant=true`, then `signal` is the `value` of the signal and this value
holds for all time instants. 

`typeof(value)` must be either `<:Number` or `<:AbstractArray` with `eltype(value) <: Number`. 
"""
getRawSignal(result, name) = (false, result[name])


"""
    getNames(result)
    
Return a vector of the names that are present in result.
"""
getNames(result) = collect( keys(result) )



"""
    getDefaultHeading(result)
    
Return default heading.
"""
getDefaultHeading(result) = ""


"""
    (isConstant, sigSize, sigElType, sigUnit) = getSignalInfo(result, name)

Return information about a signal, given the `name` of the signal:

- isConstant: = true, if signal is constant.
- sigSize: size(signal)
- sigElType: Element type of signal without unit
- sigUnit: Unit of signal 
"""
function getSignalInfo(result, name)
    (isConstant, signal) = getRawSignal(result,name)
    if isnothing(signal)
        return (isConstant, -1, nothing, nothing, nothing)
    elseif ismissing(signal)
        return (isConstant, -1, missing, missing, missing)
    elseif length(signal) == 0
        return (isConstant, -1, nothing, nothing, nothing)    
    end
    value       = isConstant ? signal : signal[1]
    valueSize   = size(value)
    valueUnit   = unit(value[1])

    if typeof(value) <: MonteCarloMeasurements.Particles
        elTypeAsString = string(typeof(ustrip.(value[1])))
        nparticles     = length(value)
        valueElType    = "MonteCarloMeasurements.Particles{" * elTypeAsString * ",$nparticles}"
    elseif typeof(value) <: MonteCarloMeasurements.StaticParticles
        elTypeAsString = string(typeof(ustrip.(value[1])))
        nparticles     = length(value)        
        valueElType    = "MonteCarloMeasurements.StaticParticles{" * elTypeAsString * ",$nparticles}"    
    else
        valueElType = typeof( ustrip.(value) ) 
    end
    nTime = length(signal)
    return (isConstant, nTime, valueSize, valueElType, valueUnit)
end



###################################################################################
#
# Utility functions to return the desired part of a signal and the heading
#
###################################################################################


"""
    (signal, isConstant, arrayName, arrayIndices) = getSignal(result, name)
    
Return the signal defined by `name::AbstractString`.
`name` may include an array range, such as "a.b.c[2:3,5]".
In this case `arrayName` is the name without the array indices,
such as `"a.b.c"` and arrayIndices is a tuple with the array indices,
such as `(2:3, 5)`. Otherwise `arrayName = name, arrayIndices=()`.

In case the signal is not known or `name` cannot be interpreted,
`(nothing, false, name, ())` is returned.

If `isConstant=false`, then `signal[i]` is the `value` of the signal at time instant `i`.

If `isConstant=true`, then `signal` is the `value` of the signal and this value
holds for all time instants. 

`typeof(value)` is either `<:Number` or `<:AbstractArray` with `eltype(value) <: Number`.

The following `Number` types are currently supported for signal elements sigElement:

1. `convert(Float64, sigElement)` is supported
   (for example Float32, Float64, DoubleFloat, Rational, Int32, Int64, Bool).
  
2. Measurements.Measurement{<Type of (1)>}.

3. MonteCarloMeasurements.StaticParticles{<Type of (1)>}.

4. MonteCarloMeasurements.Particles{<Type of (1)>}.
"""
function getSignal(result, name::AbstractString)
    sigPresent = false
    if hasSignal(result, name)
        (isConstant, sig) = getRawSignal(result, name)
        if !( isnothing(sig) || ismissing(sig) || length(sig) == 0 )
            sigPresent   = true
            value        = isConstant ? sig : sig[1]    
            arrayName    = name        
            arrayIndices = ndims(value) == 0 ? () : Tuple(1:Int(ni) for ni in size(value)) 
        end
        
    else
        # Handle signal arrays, such as a.b.c[3] or a.b.c[2:3, 1:5, 3]
        if name[end] == ']'      
            i = findlast('[', name)
            if i >= 2
                arrayName = name[1:i-1]
                indices   = name[i+1:end-1]                 
                if hasSignal(result, arrayName)
                    (isConstant, sig2) = getRawSignal(result, arrayName)
                    if !( isnothing(sig2) || ismissing(sig2) || length(sig2) == 0 )   
                        # Determine indices as tuple
                        arrayIndices = eval( Meta.parse( "(" * indices * ",)" ) )               
                        
                        # Extract sub-matrix
                        if isConstant
                            sig = getindex(sig2, arrayIndices...)
                        else
                            sig = [getindex(sig2[i], arrayIndices...) for i in eachindex(sig2)]
                        end
                        sigPresent = true
                    end
                end
            end
        end
    end

    if sigPresent
        return (sig, isConstant, arrayName, arrayIndices)
    else
        return (nothing, false, name, ())
    end
end


"""
    (signal, isConstant, arrayName, arrayIndices) = getSignalWithWarning(result, name)
    
Calls getSignal(result,name) and prints a warning message if `signal == nothing`
"""
function getSignalWithWarning(result,name)
    (signal, isConstant, arrayName, arrayIndices) = getSignal(result,name)
    if isnothing(signal)
        @warn "ModiaPlot: \"$name\" is not correct or is not defined or has no values."
    end
    return (signal, isConstant, arrayName, arrayIndices)
end


appendUnit2(name, unit) = unit == "" ? name : string(name, " [", unit, "]")


function appendUnit(name, value)
    if typeof(value) <: MonteCarloMeasurements.StaticParticles ||
       typeof(value) <: MonteCarloMeasurements.Particles
        appendUnit2(name, string(unit(value.particles[1])))
    else
        appendUnit2(name, string(unit(value)))
    end
end



"""
    (xsig, xsigLegend, ysig, ysigLegend, yIsConstant) = getPlotSignal(result, xsigName, ysigName)

Given the `AbstractString` key of the x-signal (`xsigName`) and of the y-signal (`ysigName`), returns

- `xsig`: the x-axis vector, 
- `ysig`: the y-axis vector(s),
- `xsigLegend`: the legend of the x-axis vector as String, 
- `ysigLegend`: the legend of the y-axis vector(s) as String vector,
- `yIsConstant`: whether ysig is a constant signal (= true) or not (=false).

If an element of `ysigName` is a scalar, then `ysig` is a vector 
and `ysig[i]` is the value at time instant `i`.

If an element of `ysigName` is an array, then `ysig` is a matrix, where 
ysig[i,:] are the array values at time instant `i`.
"""
function getPlotSignal(result, xsigName::AbstractString, ysigName::AbstractString)
    # Get x-axis signal
    (xsig, xIsConstant, dummy1, dummy2) = getSignalWithWarning(result, xsigName)
    if isnothing(xsig)  
        @goto ERROR
    elseif xIsConstant
        @warn "ModiaPlot: \"$xsigName\" is a constant and this is not allowed for the x-axis variable."
        @goto ERROR
    elseif ndims(xsig[1]) != 0
        @warn "ModiaPlot: \"$xsigName\" does not characterize a scalar variable as needed for the x-axis."
        @goto ERROR
    elseif !( typeof(xsig[1]) <: Number )    
        @warn "ModiaPlot: \"$xsigName\" has no Number type values, but values of type " * string(typeof(xsig[1])) * "."
        @goto ERROR    
    elseif typeof(xsig[1]) <: Measurements.Measurement
        @warn "ModiaPlot: \"$xsigName\" is a Measurements.Measurement type and this is not supported for the x-axis."
        @goto ERROR    
    elseif typeof(xsig[1]) <: MonteCarloMeasurements.StaticParticles
        @warn "ModiaPlot: \"$xsigName\" is a MonteCarloMeasurements.StaticParticles type and this is not supported for the x-axis."
        @goto ERROR  
    elseif typeof(xsig[1]) <: MonteCarloMeasurements.Particles
        @warn "ModiaPlot: \"$xsigName\" is a MonteCarloMeasurements.Particles type and this is not supported for the x-axis."
        @goto ERROR  
    end
    xsigLegend = appendUnit(xsigName, xsig[1])

    # Get y-axis signals
    (ysig, yIsConstant, yArrayName, yArrayIndices) = getSignalWithWarning(result, ysigName)
    if isnothing(ysig)
        @goto ERROR
    elseif !yIsConstant && length(ysig) != length(xsig)
        println("before warning message")
        @warn "ModiaPlot: \"$xsigName\" (= x-axis) has length " * string(length(xsig)) * 
              " but \"$ysigName\" (= y-axis) has length " * string(length(ysig)) * "."
        @goto ERROR      
    end

    value = yIsConstant ? ysig : ysig[1]
 
    if !(typeof(value) <: Number || typeof(value) <: AbstractArray)
        @warn "ModiaBase: \"$ysigName\" has no Number or AbstractArray values, but values of type " * string(typeof(value))
        @goto ERROR 
    end

    if ndims(value) == 0
        # ysigName is a scalar variable
        ysigLegend = [appendUnit(ysigName, value)]        
        if yIsConstant 
            # Construct a constant time series with two points at the first and the last value of the time vector
            xsig = [xsig[1], xsig[end]]
            ysig = [ysig   , ysig     ]
        end
        
    else
        # ysigName is an array variable
        if yIsConstant      
            xsig = [xsig[1], xsig[end]]
            ysig = reshape(ysig, :)
            ysig = collect([ysig ysig]')    
        else
            nvalue = length(value)        
            ysig2  = ysig
            ysig   = zeros(eltype(value), length(xsig), nvalue)
            for (i, value_i) in enumerate(ysig2)
                for j in 1:nvalue
                    ysig[i,j] = ysig2[i][j]  
                end
            end
        
        end
        
        nLegend    = size(ysig,2)       
        ysigLegend = [yArrayName * "[" for i = 1:nLegend]
        i = 1
        ySizeLength = Int[]        
        for j1 in eachindex(yArrayIndices)
            push!(ySizeLength, length(yArrayIndices[j1]))
            i = 1
            if j1 == 1
                for j2 in 1:div(nLegend, ySizeLength[1])
                    for j3 in yArrayIndices[1]
                        ysigLegend[i] *= string(j3)
                        i += 1
                    end
                end
            else
                ncum = prod( ySizeLength[1:j1-1] )
                for j2 in yArrayIndices[j1]
                    for j3 = 1:ncum
                        ysigLegend[i] *= "," * string(j2)                       
                        i += 1
                    end
                end
            end
        end
        value = ysig[1]
        for i = 1:nLegend
            ysigLegend[i] *= appendUnit("]", value)
        end
    end
           
    return (ustrip.(xsig), xsigLegend, ustrip.(ysig), ysigLegend, yIsConstant)
    
    @label ERROR
    return (nothing, nothing, nothing, nothing, nothing)
end

getHeading(result, heading) = heading != "" ? heading : getDefaultHeading(result)


"""
    prepend!(prefix, ysigLegend)
    
Add `prefix` string in front of every element of the `ysigLegend` string-Vector.
"""
function prepend!(prefix::AbstractString, ysigLegend::Vector{AbstractString})
   for i in eachindex(ysigLegend)
      ysigLegend[i] = prefix*ysigLegend[i]
   end
   return ysigLegend
end



###################################################################################
#
# Exported functions
#
###################################################################################


"""
    printResultInfo(result)
    
Print names, sizes, units and element types of the signals that are stored in result.
"""
function printResultInfo(result)
    if isnothing(result)
        @info "The call of ModiaPlot.printResultInfo(result) is ignored, since the first argument is nothing."
        return
    end
    
    resultInfoTable = DataFrames.DataFrame(name=String[], unit=String[], constant=Bool[], varSize=String[], eltype=String[])

    nTime = -1
    first = true
    firstTimeSignal = ""
    for name in getNames(result)
        (isConstant, nTime2, varSize, elType, unit) = getSignalInfo(result, name)
        if !isConstant && !isnothing(varSize) && !ismissing(varSize)
            if first 
                first = false
                nTime = nTime2
                firstTimeSignal = name
            elseif nTime != nTime2
                @warn "\"$name\" has $nTime2 time points but \"$firstTimeSignal\" has $nTime time points."
            end
        end
        push!(resultInfoTable, [name, string(unit), isConstant, string(varSize), string(elType)] )
    end

    # eltypes=false, truncate=50: Requires and older version of DataFrames
    show(stdout, resultInfoTable, summary=false, rowlabel=Symbol("#"), allcols=true)
    if nTime != -1
        println("\n... Number of time points = ", nTime)
    else
        println()
    end    
end


"""
    plot(result, names; 
         heading = "", grid = true, xAxis = "time",
         figure = 1, prefix = "", reuse = false, maxLegend = 10,
         minXaxisTickLabels = false,
         MonteCarloAsArea = true)

Generate **line plots** of the signals of the `result` data structure that are
identified with the `names` keys.

By default `result` is any type of dictionary with key type `::AbstractString` and value type `::Any`.
By providing own implementations of some access-functions, other `result` data structures can be used
(for details see xxx).

Argument `names` defines the diagrams to be drawn and the result data to be included in the respective diagram:

- If `names` is a **String**, generate one diagram with one time series of the variable with key `names`.

- If `names` is a **Tuple** of Strings, generate one diagram with the time series of the variables
  with the keys given in the tuple.
  
- If names is a **Vector** or a **Matrix** of **Strings** and/or **Tuples**, 
  generate a vector or matrix of diagrams.

Note, the names (and their units, if available in the result) are automatically used as legends in the
respective diagram.

A signal variable identified by a `String` key can be a scalar of type `<:Number`
or an array of element type `<:Number`. A signal can be either a **constant** or a **time series** 
where for every time instant one value of the signal variable
is stored in `result` (time instants are along the first dimension of an array). 
In case of a constant, a constant line is drawn for the first to the last time 
instant.

Note, before passing data to the plot package,
it is converted to Float64. This allows to, for example, also plot rational numbers,
even if not supported by the plot package. `Measurements.Measurement{xxx}` is specially handled.
  

# Optional Arguments
- `heading::AbstractString`: Optional heading above the diagram.

- `grid::Bool`: = true, to display a grid.

- `xAxis::AbstractString`: Name of x-axis.

- `figure::Int`: Integer identifier of the window in which the diagrams shall be drawn.

- `prefix::AbstractString`: String that is appended in front of every legend label 
  (useful especially if `reuse=true`).
  
- `reuse::Bool`: If figure already exists and reuse=false, clear the figure before adding the plot.
   Otherwise, include the plot in the existing figure without removing the curves present in the figure.

- `maxLegend::Int`: If the number of legend entries in one plot command `> maxLegend`, 
  the legend is suppressed.
  All curves have still their names as labels. In PyPlot, the curves can be inspected by 
  their names by clicking in the toolbar of the plot on button `Edit axis, curve ..` 
  and then on `Curves`.

- `minXaxisTickLabels::Bool`: = true, if xaxis tick labels shall be
  removed in a vector or array of plots, if not the last row
  (useful when including plots in a document).
  = false, x axis tick labels are always shown (useful when interactively zooming into a plot).

- `MonteCarloAsArea::Bool`: = true, if MonteCarloMeasurements values are shown with the mean value
  and the area between the minimum and the maximum value of all particles.
  = false, if all particles of MonteCarloMeasurements values are shown (e.g. if a value has 2000 particles,
  then 2000 curves are shown in the diagram).

# Examples
```julia
using ModiaPlot
using Unitful

# Construct result data
t = range(0.0, stop=10.0, length=100);
result = Dict{AbstractString,Any}();
result["time"] = t*u"s";
result["phi"]  = sin.(t)*u"rad";
result["w"]    = cos.(t)*u"rad/s";
result["a"]    = 1.2*sin.(t)*u"rad/s^2";
result["r"]    = hcat(0.4 * cos.(t), 0.5 * sin.(t), 0.3*cos.(t))*u"m";

# 1 signal in one diagram (legend = "phi [rad]")
plot(result, "phi")

# 3 signals in one diagram
plot(result, ("phi", "w", "a"), figure=2)

# 3 diagrams in form of a vector (every diagram has one signal)
plot(result, ["phi", "w", "r"], figure=3)

# 4 diagrams in form of a matrix (every diagram has one signal)
plot(result, ["phi" "w";
              "a"   "r[2]" ], figure=4)

# 2 diagrams in form of a vector
plot(result, [ ("phi", "w"), ("a") ], figure=5)

# 4 diagrams in form of a matrix
plot(result, [ ("phi",)           ("phi", "w");
               ("phi", "w", "a")  ("r[2:3]",)     ],figure=6)

# Plot w=f(phi) in one diagram
plot(result, "w", xAxis="phi", figure=7)

# Append signal of the next simulation run to figure=1
# (legend = "Sim 2: phi [rad]")
result["phi"] = 0.5*result["phi"];
plot(result, "phi", prefix="Sim 2: ", reuse=true)
```

Example of a matrix of plots:

![Matrix of plots](../resources/images/matrix-of-plots.png)
"""
plot(result, names::AbstractString; kwargs...) = plot(result, [names]        ; kwargs...) 
plot(result, names::Symbol        ; kwargs...) = plot(result, [string(names)]; kwargs...)
plot(result, names::Tuple         ; kwargs...) = plot(result, [names]        ; kwargs...) 
plot(result, names::AbstractVector; kwargs...) = plot(result, reshape(names, length(names), 1); kwargs...)

