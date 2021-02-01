# License for this file: MIT (expat)
# Copyright 2017-2020, DLR Institute of System Dynamics and Control


"""
    module ModiaPlot

Organize and plot simulation result data (time series).
The [`ModiaPlot.plot`](@ref) function of this
module allows to plot the result data by giving the signal names.
The legends/labels of the plots are automatically constructed by the
signal names and their unit. Example:

```julia
ModiaPlot.plot(result, [ (:phi,:r)      (:phi,:phi2,:w);
                         (:w,:w2,:phi2) (:phi,:w)      ],
               heading="Matrix of plots")
```

generates the following plot:

![Matrix-of-Plots](../../resources/images/matrix-of-plots.svg)

# Main developer

[Martin Otter](https://rmc.dlr.de/sr/en/staff/martin.otter/),
[DLR - Institute of System Dynamics and Control](https://www.dlr.de/sr/en)
"""
module ModiaPlot

export plot, showFigure, saveFigure, closeFigure, closeAllFigures, printResultInfo


# using/imports
import DataFrames
import Colors
import Measurements
import MonteCarloMeasurements
using  Unitful


# Constants
const headingSize = 10


const path = dirname(dirname(@__FILE__))   # Absolute path of package directory
const Version = "0.7.0-dev"
const Date = "2021-01-31"

println("\nImporting ModiaPlot Version $Version ($Date) - this takes some time due to GLMakie import")


include("plot_base.jl")
include("plot_with_GLMakie.jl")

end