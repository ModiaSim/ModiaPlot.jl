
export makeSameTimeAxis, compareResults

#=
Compare result data

* Developer: Martin Otter, DLR-SR
* First version: May 2021
* License: MIT (expat)
=#


using  ModiaPlot
import DataFrames
import Unitful


baseType(::Type{T}) where {T}  = T
numberType(value) = baseType(eltype(value))

function ifNecessaryStripUnits(s1,s2)
    if   numberType(s1) <: Unitful.AbstractQuantity &&
       !(numberType(s2) <: Unitful.AbstractQuantity)
        # s1 has units and s2 has no units -> remove units in s1
        s1 = Unitful.ustrip.(s1)
    elseif !(numberType(s1) <: Unitful.AbstractQuantity) &&
             numberType(s2) <: Unitful.AbstractQuantity
        # s1 has no units and s2 has units -> remove units in s2
        s2 = Unitful.ustrip.(s2)
    end
    return (s1,s2)
end


# Overload ModiaPlot methods
ModiaPlot.hasSignal(   df::DataFrames.DataFrame, name) = name in DataFrames.names(df)
ModiaPlot.getRawSignal(df::DataFrames.DataFrame, name) = (false, df[!,name])
ModiaPlot.getNames(    df::DataFrames.DataFrame)       = DataFrames.names(df)


# Provide Vector type with one value and fixed length
struct OneValueVector{T} <: AbstractArray{T, 1}
    value::T
    nvalues::Int
    OneValueVector{T}(value,nvalues) where {T} = new(value,nvalues)
end
OneValueVector(value,nvalues) = OneValueVector{typeof(value)}(value,nvalues)

Base.getindex(v::OneValueVector, i::Int)  = v.value
Base.size(v::OneValueVector)              = (v.nvalues,)
Base.IndexStyle(::Type{<:OneValueVector}) = IndexLinear()



interpolate(tsig, sig, isig, t) = begin
                                      sig_ipo = sig[isig-1] + (sig[isig] - sig[isig-1])*((t - tsig[isig-1])/(tsig[isig] - tsig[isig-1]))
                                      isfinite(sig_ipo) ? sig_ipo : sig[isig]
                                  end
                                                      
                                    
"""
    (result1s, result2s, sameTimeRange) = makeSameTimeAxis(result1, result2;
                                                           names     = missing,
                                                           timeName1 = "time",
                                                           timeName2 = "time")
    
The function makes the same time axis for the signals in result1 and result2 identified
by the signal `names::Vector{String}`. It is required that `result1` and `result2` support functions 

- `hasSignal(result, name)`
- `getRawSignal(result, name)`
- `getNames(result)`

and that the time axis is identified by name `timeName1` and `timeName2` respectively.
If `names == missing`, then the intersection of the `names` of `result1` and of `result2`
is used (but without signals `timeName1`, `timeName2).

The function returns a dictionaries of type `DictionaryResult` of the signals 
`names` that are both in `result1` and
in `result2` so that all signals have the same time axes.

Notes:

- If for example `names = ["n1", "n2", "n3", "n4"]` and `"n1"`, `"n3"` and `"n4"`are in `result1`
  and `"n2", "n3", "n4"` are in `result2` then `result1s` and `result2s` contain names
  `"n3", "n4"`.

- If additional time instants are introduced in a time axis, then the corresponding 
  signal values are computed by linear interpolation.

- If possible, **references** are returned and **not copies** of the signals (for example, if the
  time axes of `result1` and `result2` are identical, then `result1s` is a reference of
  `result1` and `result2s` is a reference of `result2`). 
  
- If the first and last time point of result1 and result2 are identical, 
  then `sameTimeRange = true`. If this is not the case, `sameTimeRange = false` and 
  time vectors in `result1s, result2s` contain the time values 
  that are both in time vectors `result1` and `result2`. 
  If there is no common time range, an error occurs.
"""
function makeSameTimeAxis(result1, result2;
                          names = missing, 
                          timeName1::String = "time",
                          timeName2::String = "time")
 
    # Determine the names that are both in result1 and in result2
    names_common::Vector{String} = ismissing(names) ? 
        setdiff(intersect(ModiaPlot.getNames(result1), ModiaPlot.getNames(result2)), [timeName1, timeName2]) :
        intersect(names, ModiaPlot.getNames(result1), ModiaPlot.getNames(result2))
    if length(names_common) == 0
        @error "result1 and result2 have no names in common from $names"
    end  
    
    # Check that timename1 and timeName2 are in the results
    if !ModiaPlot.hasSignal(result1, timeName1)
        @error "result1 has no signal with name $timeName1"
    elseif !ModiaPlot.hasSignal(result2, timeName2)
        @error "result2 has no signal with name $timeName2"
    end
    
    # Get time axes    
    (isConstant1, t1) = ModiaPlot.getRawSignal(result1, timeName1)
    (isConstant2, t2) = ModiaPlot.getRawSignal(result2, timeName2)
    if !(typeof(t1) <: AbstractVector)
        type_t1 = typeof(t1)
        @error "The time signal $timeName1 of result1 is no vector (has type $type_t1)"
    elseif !(typeof(t2) <: AbstractVector)
        type_t2 = typeof(t2)   
        @error "The time signal $timeName2 of result2 is no vector (has type $type_t2)"
    end
    (t1,t2) = ifNecessaryStripUnits(t1,t2)
    
    # Generate output dictionaries
    #result1s = OrderedDict{String, Any}()
    #result2s = OrderedDict{String, Any}()
    #result1s = DictionaryResult()
    #result2s = DictionaryResult()    
    result1s = DataFrames.DataFrame()
    result2s = DataFrames.DataFrame()
    
    # Handle case, if the time axes are the same
    if t1 == t2
        nt = length(t1)
        (isConstant1, sig1) = ModiaPlot.getRawSignal(result1, timeName1)
        result1s[!,timeName1] = sig1
        (isConstant2, sig2) = ModiaPlot.getRawSignal(result2, timeName2)
        result2s[!,timeName2] = sig2         
        for name in names_common
            (isConstant1, sig1) = ModiaPlot.getRawSignal(result1, name)
            result1s[!,name] = isConstant1 ? OneValueVector(sig1,nt) : sig1
            (isConstant2, sig2) = ModiaPlot.getRawSignal(result2, name)
            result2s[!,name] = isConstant2 ? OneValueVector(sig2,nt) : sig2
        end
        return (result1s, result2s, true)
    end
    
    # Determine common time range
    nt1 = length(t1)
    nt2 = length(t2)
    if t1[end] < t2[1] || t1[1] > t2[end]
        t1_begin = t1[1]
        t1_end   = t1[end]
        t2_begin = t2[1]
        t2_end   = t2[end]
        @error "result1 has time range [$t1_begin,$t1_end] and result2 has time range [$t1_begin,$t1_end]"
    end  

    if t1[1] <= t2[1]
        i1_begin = findlast(v -> v <= t2[1], t1)
        i2_begin = 1
        t_begin  = t2[1]
    else
        i2_begin = findlast(v -> v <= t1[1], t2)
        i1_begin = 1
        t_begin  = t1[1]
    end
    
    # Allocate memory for common time axis
    nt  = nt1 + nt2
    t_common = similar(t1, promote_type(eltype(t1), eltype(t2)), nt)  
    t  = t_begin
    i1 = i1_begin
    i2 = i2_begin
    i  = 1
    while true
        t_common[i] = t

        if t >= t1[i1]
            i1 += 1
        end
        
        if t >= t2[i2]
            i2 += 1
        end     

        i += 1
        if i > nt
            break
        elseif i1 > nt1 || i2 > nt2
            deleteat!(t_common, i:nt)
            break
        end
        
        t = t1[i1] <= t2[i2] ? t1[i1] : t2[i2]            
    end
    result1s[!,timeName1] = t_common
    result2s[!,timeName2] = t_common
    nt = length(t_common)
    sameTimeRange = t1[1] == t2[1] && t1[end] == t2[end]
  
    # Make same time axis
    for name in names_common
        # Allocate memory for signals in result1s, result2s
        (isConstant1, sig1) = ModiaPlot.getRawSignal(result1, name)
        (isConstant2, sig2) = ModiaPlot.getRawSignal(result2, name) 
        
        if isConstant1 && isConstant2
            # The signals are both constant
            sig1_common = OneValueVector(sig1,nt)
            sig2_common = OneValueVector(sig2,nt)
            
        else 
            if isConstant1 || isConstant2
                if isConstant1
                    sig1 = OneValueVector(sig1,nt1) 
                end
                if isConstant2
                    sig2 = OneValueVector(sig2,nt2)
                end
            else
                if length(sig1) == 0
                    @error "$name in result1 has no values"
                end
                if length(sig2) == 0
                    @error "$name in result2 has no values"
                end
            end
            
            if typeof(sig1[1]) <: Number && typeof(sig2[1]) <: Number
                sig1_common = similar(sig1, promote_type(eltype(sig1), eltype(sig2)), nt)
            elseif typeof(sig1[1]) <: AbstractArray && typeof(sig2[1]) <: AbstractArray 
                if size(sig1[1]) != size(sig2[1])
                    size1 = size(sig1[1])
                    size2 = size(sig2[1])
                    @error "$name array in result1 has element size $size1 and in result2 element size $size2"
                end
                sig1_common = similar(sig1, Array{promote_type(eltype(sig1[1]), eltype(sig2[1])), ndims(sig1[1])}, nt)
            else
                type1 = typeof(sig1[1])
                type2 = typeof(sig2[1])
                @error "$name in result1 has element type $type1 and in result2 element type $type2"
            end     
            sig2_common = similar(sig1_common)
            
            # Make same time axis for signals sig1 and sig2
            t  = t_begin
            i  = 1
            i1 = i1_begin
            i2 = i2_begin
            while true    
                #println("... i = $i, i1 = $i1, i2 = $i2, t = $t, t1[i1] = ", t1[i1], ", t2[i2] = ", t2[i2])
                
                if t < t1[i1]
                    sig1_common[i] = interpolate(t1,sig1,i1,t)
                else
                    sig1_common[i] = sig1[i1]
                    i1 += 1
                end
                
                if t < t2[i2]
                    sig2_common[i] = interpolate(t2,sig2,i2,t)
                else
                    sig2_common[i] = sig2[i2]
                    i2 += 1
                end     
    
                i += 1
                if i > nt
                    break
                end
                
                t = t1[i1] <= t2[i2] ? t1[i1] : t2[i2]                 
            end
        end
        result1s[!,name] = sig1_common
        result2s[!,name] = sig2_common
    end
    return (result1s, result2s, sameTimeRange)
end



"""
    (success, diff, diff_names, max_error, within_tolerance) = 
                      compareResults(result, reference;
                                     tolerance     = 1e-3,
                                     names         = missing,
                                     timeResult    = "time",
                                     timeReference = "time")
    
Compare the signals identified by `names::Vector{String}` in `result` 
with the reference reults `reference` using the relative `tolerance`.
The time axis is identified by name `timeResult` and `timeReference` respectively.
If `names == missing`, then the intersection of the `names` of `result` and of `reference`
is used (but without signals `timeResult`, `timeReference).

Input arguments `result`, `reference` can be dictionaries, DataFrames or 
objects that support functions 

- `ModiaPlot.hasSignal(result, name)`
- `ModiaPlot.getRawSignal(result, name)`
- `ModiaPlot.getNames(result)`


# Output arguments

- `success::Bool`: = true, if all compared signals are the same within the given tolerance (see below),.
- `diff::DataFrame`: The difference of the compared signals (using `timeResult` as time-axis).
- `diff_names::Vector{String}`: The names of the signals that are compared.
- `max_error::Vector{Float64}`: max_error[i] is the maximum error in signal of diff_names[i].
- `within_tolerance::BitVector`: withinTolerance[i] = true, if signal of diff_names[i] is within the tolerance (see below).


# Computation of the outputs

Comparison is made in the following way (assuming `result` and `reference`
have the same time axis and are DataFrames objects):

```julia
smallestNominal = 1e-10
nt = DataFrames.nrow(reference)
for (i,name) in enumerate(diff_names)
    diff[i]             = result[!,name] - reference[!,name]
    max_error[i]        = maximum( abs.(result[!,name] - reference[!,name]) )
    nominal[i]          = max( sum( abs.(reference[!,name])/nt ), smallestNominal )
    within_tolerance[i] = max_error[i] <= nominal[i]*tolerance 
end
success = all(within_tolerance)
```

# Notes

Before the comparison, the function makes the same time axis for the signals in 
`result` and `reference` and selects the maximum time range that is both in `result` and in
`reference`. If additional time instants are introduced in a time axis, 
then the corresponding signal values are computed by linear interpolation.
This linear interpolation can introduce a significant error.
It is therefore highly recommended to use the same time axis.
"""
function compareResults(result, reference;
                        tolerance::Float64 = 1e-3,
                        names::Union{Missing,Vector{String}} = missing, 
                        timeResult::String = "time",
                        timeReference::String = "time")
    # Check tolerance
    if tolerance <= 0.0
        @error "compareResults: Input argument tolerance = $tolerance <= 0.0"
    end
    
    # Make same time axis
    (result1s, result2s) = makeSameTimeAxis(result, reference;
                                            names = names, 
                                            timeName1 = timeResult,
                                            timeName2 = timeReference)

    # Compute difference and tolerance
    diff_names = setdiff(DataFrames.names(result1s), [timeResult])
    nnames = length(diff_names)
    diff = DataFrames.DataFrame()
    diff[!,timeResult] = result1s[!,timeResult]
    smallestNominal = 1e-10
    nt = DataFrames.nrow(result1s)
    max_error = zeros(nnames)
    nominal   = zeros(nnames)
    within_tolerance = fill(false, nnames)
    for (i,name) in enumerate(diff_names)
        s1 = result1s[!,name]
        s2 = result2s[!,name]
        (s1,s2) = ifNecessaryStripUnits(s1,s2)
        
        # Difference of the signals
        diff[!,name] = s1 - s2
        
        # Error
        max_error[i] = Unitful.ustrip.( maximum( abs.(s1 - s2) ) )
        nominal[i]   = max( Unitful.ustrip(sum( abs.(s2)/nt )), smallestNominal )
        within_tolerance[i] = max_error[i] <= nominal[i]*tolerance 
    end
    success = all(within_tolerance)
    
    return (success, diff, diff_names, max_error, within_tolerance)
end
