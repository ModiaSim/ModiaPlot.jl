# ModiaPlot.jl Documentation

Package ModiaPlot provides a convenient interface to produce
line plots of time series data where a time series is identified by a String key.
The legends/labels of the plots are automatically constructed by the
keys and the units of the time series. Example:

```julia
# result is a dictionary Dict{String,Any}.
ModiaPlot.plot(result, [ ("phi", "r")        ("phi", "phi2", "w");
                         ("w", "w2", "phi2") "w"                ],
               heading="Matrix of plots")
```

generates the following plot:

![Matrix-of-Plots](../resources/images/matrix-of-plots.png)

The underlying line plot is generated by GLMakie.



## Installation

The package is not yet registered. It can be installed in the following way
(Julia >= 1.5 is required):

```julia
julia> ]add https://github.com/ModiaSim/ModiaPlot.jl#main
```

## Release Notes

### Version 0.7.0

- Initial version, based on code developed for ModiaMath 0.6.x.


## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)
