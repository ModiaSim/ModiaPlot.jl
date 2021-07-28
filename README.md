> ⚠️ **INFO: This repository is deprecated**
> 
> Do no longer use this repository. Use instead [ModiaResult.jl](https://github.com/ModiaSim/ModiaResult.jl).
> For more details, see [ModiaSim](https://modiasim.github.io/docs/). 


# ModiaPlot

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://modiasim.github.io/ModiaPlot.jl/stable/)
[![The MIT License](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](https://github.com/ModiaSim/ModiaPlot.jl/blob/master/LICENSE.md)

ModiaPlot is part of [ModiaSim](https://modiasim.github.io/docs/). 

ModiaPlot provides a convenient interface to produce
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

![Matrix-of-Plots](docs/resources/images/matrix-of-plots.png)

The underlying line plot is generated by GLMakie.


## Installation

The package is registered and is installed with (Julia >= 1.5 is required):

```julia
julia> ]add ModiaPlot
```

It is recommended to also add the following packages, in order that all tests can be executed
in an own environment (`]test ModiaPlot` works without adding these packages).

```julia
julia> ]add Unitful, DataStructures, Measurements, MonteCarloMeasurements, Distributions
```


## Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)
