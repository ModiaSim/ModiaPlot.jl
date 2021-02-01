var documenterSearchIndex = {"docs":
[{"location":"Internal.html#Internal","page":"Internal","title":"Internal","text":"","category":"section"},{"location":"Internal.html","page":"Internal","title":"Internal","text":"CurrentModule = ModiaPlot","category":"page"},{"location":"Internal.html","page":"Internal","title":"Internal","text":"This chapter documents the functions that can be specially defined for own result data structures.","category":"page"},{"location":"Internal.html","page":"Internal","title":"Internal","text":"Functions Description\nhasSignal Returns true if signal is available in result\ngetRawSignal Returns the raw signal from result\ngetNames Return a vector of the names that are present in result\ngetDefaultHeading Return default heading\ngetSignalInfo Return information about a signal","category":"page"},{"location":"Internal.html#Access-Result","page":"Internal","title":"Access Result","text":"","category":"section"},{"location":"Internal.html","page":"Internal","title":"Internal","text":"hasSignal\r\ngetRawSignal\r\ngetNames\r\ngetDefaultHeading\r\ngetSignalInfo","category":"page"},{"location":"Internal.html#ModiaPlot.hasSignal","page":"Internal","title":"ModiaPlot.hasSignal","text":"hasSignal(result, name)\n\nReturns true if signal name is available in result.\n\n\n\n\n\n","category":"function"},{"location":"Internal.html#ModiaPlot.getRawSignal","page":"Internal","title":"ModiaPlot.getRawSignal","text":"(isConstant, signal) = getRawSignal(result, name)\n\nReturns result time series signal of name (an error is raised, if name is not known).\n\nIf isConstant=false, then signal[i] is the value of the signal at time instant i.\n\nIf isConstant=true, then signal is the value of the signal and this value holds for all time instants. \n\ntypeof(value) must be either <:Number or <:AbstractArray with eltype(value) <: Number. \n\n\n\n\n\n","category":"function"},{"location":"Internal.html#ModiaPlot.getNames","page":"Internal","title":"ModiaPlot.getNames","text":"getNames(result)\n\nReturn a vector of the names that are present in result.\n\n\n\n\n\n","category":"function"},{"location":"Internal.html#ModiaPlot.getDefaultHeading","page":"Internal","title":"ModiaPlot.getDefaultHeading","text":"getDefaultHeading(result)\n\nReturn default heading.\n\n\n\n\n\n","category":"function"},{"location":"Internal.html#ModiaPlot.getSignalInfo","page":"Internal","title":"ModiaPlot.getSignalInfo","text":"(isConstant, sigSize, sigElType, sigUnit) = getSignalInfo(result, name)\n\nReturn information about a signal, given the name of the signal:\n\nisConstant: = true, if signal is constant.\nsigSize: size(signal)\nsigElType: Element type of signal without unit\nsigUnit: Unit of signal \n\n\n\n\n\n","category":"function"},{"location":"Functions.html#Functions","page":"Functions","title":"Functions","text":"","category":"section"},{"location":"Functions.html","page":"Functions","title":"Functions","text":"CurrentModule = ModiaPlot","category":"page"},{"location":"Functions.html","page":"Functions","title":"Functions","text":"This chapter documents the exported functions of ModiaPlot.","category":"page"},{"location":"Functions.html","page":"Functions","title":"Functions","text":"Functions Description\nplot Plot simulation results in multiple diagrams/figures\nprintResultInfo Print info of the signals that are stored in result\ncloseFigure Close one figure\ncloseAllFigures Close all figures\nshowFigure Show figure in window\nsaveFigure Save figure in png, jpg or bmp format","category":"page"},{"location":"Functions.html#Interactive-Commands","page":"Functions","title":"Interactive Commands","text":"","category":"section"},{"location":"Functions.html","page":"Functions","title":"Functions","text":"Once a plot window has been created, then the following interactive commands are available:","category":"page"},{"location":"Functions.html","page":"Functions","title":"Functions","text":"Functionality GLMakie\nZoom Mouse wheel scrolling\nPan Mouse right click and dragging\nSave in png, jpg, bmp format saveFigure","category":"page"},{"location":"Functions.html#Plot-Functions","page":"Functions","title":"Plot Functions","text":"","category":"section"},{"location":"Functions.html","page":"Functions","title":"Functions","text":"plot\r\nprintResultInfo\r\ncloseFigure\r\ncloseAllFigures\r\nshowFigure\r\nsaveFigure","category":"page"},{"location":"Functions.html#ModiaPlot.plot","page":"Functions","title":"ModiaPlot.plot","text":"plot(result, names; \n     heading = \"\", grid = true, xAxis = \"time\",\n     figure = 1, prefix = \"\", reuse = false, maxLegend = 10,\n     minXaxisTickLabels = false,\n     MonteCarloAsArea = true)\n\nGenerate line plots of the signals of the result data structure that are identified with the names keys.\n\nBy default result is any type of dictionary with key type ::AbstractString and value type ::Any. By providing own implementations of some access-functions, other result data structures can be used (for details see xxx).\n\nArgument names defines the diagrams to be drawn and the result data to be included in the respective diagram:\n\nIf names is a String, generate one diagram with one time series of the variable with key names.\nIf names is a Tuple of Strings, generate one diagram with the time series of the variables with the keys given in the tuple.\nIf names is a Vector or a Matrix of Strings and/or Tuples,  generate a vector or matrix of diagrams.\n\nNote, the names (and their units, if available in the result) are automatically used as legends in the respective diagram.\n\nA signal variable identified by a String key can be a scalar of type <:Number or an array of element type <:Number. A signal can be either a constant or a time series  where for every time instant one value of the signal variable is stored in result (time instants are along the first dimension of an array).  In case of a constant, a constant line is drawn for the first to the last time  instant.\n\nNote, before passing data to the plot package, it is converted to Float64. This allows to, for example, also plot rational numbers, even if not supported by the plot package. Measurements.Measurement{xxx} is specially handled.\n\nOptional Arguments\n\nheading::AbstractString: Optional heading above the diagram.\ngrid::Bool: = true, to display a grid.\nxAxis::AbstractString: Name of x-axis.\nfigure::Int: Integer identifier of the window in which the diagrams shall be drawn.\nprefix::AbstractString: String that is appended in front of every legend label  (useful especially if reuse=true).\nreuse::Bool: If figure already exists and reuse=false, clear the figure before adding the plot.  Otherwise, include the plot in the existing figure without removing the curves present in the figure.\nmaxLegend::Int: If the number of legend entries in one plot command > maxLegend,  the legend is suppressed. All curves have still their names as labels. In PyPlot, the curves can be inspected by  their names by clicking in the toolbar of the plot on button Edit axis, curve ..  and then on Curves.\nminXaxisTickLabels::Bool: = true, if xaxis tick labels shall be removed in a vector or array of plots, if not the last row (useful when including plots in a document). = false, x axis tick labels are always shown (useful when interactively zooming into a plot).\nMonteCarloAsArea::Bool: = true, if MonteCarloMeasurements values are shown with the mean value and the area between the minimum and the maximum value of all particles. = false, if all particles of MonteCarloMeasurements values are shown (e.g. if a value has 2000 particles, then 2000 curves are shown in the diagram).\n\nExamples\n\nusing ModiaPlot\nusing Unitful\n\n# Construct result data\nt = range(0.0, stop=10.0, length=100);\nresult = Dict{AbstractString,Any}();\nresult[\"time\"] = t*u\"s\";\nresult[\"phi\"]  = sin.(t)*u\"rad\";\nresult[\"w\"]    = cos.(t)*u\"rad/s\";\nresult[\"a\"]    = 1.2*sin.(t)*u\"rad/s^2\";\nresult[\"r\"]    = hcat(0.4 * cos.(t), 0.5 * sin.(t), 0.3*cos.(t))*u\"m\";\n\n# 1 signal in one diagram (legend = \"phi [rad]\")\nplot(result, \"phi\")\n\n# 3 signals in one diagram\nplot(result, (\"phi\", \"w\", \"a\"), figure=2)\n\n# 3 diagrams in form of a vector (every diagram has one signal)\nplot(result, [\"phi\", \"w\", \"r\"], figure=3)\n\n# 4 diagrams in form of a matrix (every diagram has one signal)\nplot(result, [\"phi\" \"w\";\n              \"a\"   \"r[2]\" ], figure=4)\n\n# 2 diagrams in form of a vector\nplot(result, [ (\"phi\", \"w\"), (\"a\") ], figure=5)\n\n# 4 diagrams in form of a matrix\nplot(result, [ (\"phi\",)           (\"phi\", \"w\");\n               (\"phi\", \"w\", \"a\")  (\"r[2:3]\",)     ],figure=6)\n\n# Plot w=f(phi) in one diagram\nplot(result, \"w\", xAxis=\"phi\", figure=7)\n\n# Append signal of the next simulation run to figure=1\n# (legend = \"Sim 2: phi [rad]\")\nresult[\"phi\"] = 0.5*result[\"phi\"];\nplot(result, \"phi\", prefix=\"Sim 2: \", reuse=true)\n\nExample of a matrix of plots:\n\n(Image: Matrix of plots)\n\n\n\n\n\n","category":"function"},{"location":"Functions.html#ModiaPlot.printResultInfo","page":"Functions","title":"ModiaPlot.printResultInfo","text":"printResultInfo(result)\n\nPrint names, sizes, units and element types of the signals that are stored in result.\n\n\n\n\n\n","category":"function"},{"location":"Functions.html#ModiaPlot.closeFigure","page":"Functions","title":"ModiaPlot.closeFigure","text":"closeFigure(figure)\n\nClose figure.\n\n\n\n\n\n","category":"function"},{"location":"Functions.html#ModiaPlot.closeAllFigures","page":"Functions","title":"ModiaPlot.closeAllFigures","text":"closeAllFigure()\n\nClose all figures.\n\n\n\n\n\n","category":"function"},{"location":"Functions.html#ModiaPlot.showFigure","page":"Functions","title":"ModiaPlot.showFigure","text":"showFigure(figure)\n\nHas only an effect for plot package GLMakie: Shows the desired figure in the single window.\n\nExample\n\nusing ModiaPlot\n...\nplot(..., figure=1)\nplot(..., figure=2)\nplot(..., figure=3)   # only this figure is shown in the window\n\nshowFigure(2)   # show figure 2 in the window\nshowFigure(1)   # show figure 1 in the window\n\n\n\n\n\n","category":"function"},{"location":"Functions.html#ModiaPlot.saveFigure","page":"Functions","title":"ModiaPlot.saveFigure","text":"saveFigure(figure, file; kwargs...)\n\nHas only an effect for plot package GLMakie: Save figure in png, jpg or bmp format on file (kwargs... is passed to function save).\n\nKeyword arguments\n\nresolution: (width::Int, height::Int) of the scene in dimensionless  units (equivalent to px for GLMakie and WGLMakie).\n\nExample\n\nusing ModiaPlot\n\nplot(..., figure=1)\nplot(..., figure=2)\n\nsaveFigure(1, \"plot.png\")   # save in png-format\nsaveFigure(2, \"plot.jpg\")   # save in jpg-format\n\n\n\n\n\n","category":"function"},{"location":"index.html#ModiaPlot.jl-Documentation","page":"Home","title":"ModiaPlot.jl Documentation","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"Package ModiaPlot provides a convenient interface to produce line plots of time series data where a time series is identified by a String key. The legends/labels of the plots are automatically constructed by the keys and the units of the time series. Example:","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"# result is a dictionary Dict{String,Any}.\r\nModiaPlot.plot(result, [ (\"phi\", \"r\")        (\"phi\", \"phi2\", \"w\");\r\n                         (\"w\", \"w2\", \"phi2\") \"w\"                ],\r\n               heading=\"Matrix of plots\")","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"generates the following plot:","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"(Image: Matrix-of-Plots)","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"The underlying line plot is generated by GLMakie.","category":"page"},{"location":"index.html#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"The package is not yet registered. It can be installed in the following way (Julia >= 1.5 is required):","category":"page"},{"location":"index.html","page":"Home","title":"Home","text":"julia> ]add https://github.com/ModiaSim/ModiaPlot.jl#main","category":"page"},{"location":"index.html#Release-Notes","page":"Home","title":"Release Notes","text":"","category":"section"},{"location":"index.html#Version-0.7.0","page":"Home","title":"Version 0.7.0","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"Initial version, based on code developed for ModiaMath 0.6.x.","category":"page"},{"location":"index.html#Main-developer","page":"Home","title":"Main developer","text":"","category":"section"},{"location":"index.html","page":"Home","title":"Home","text":"Martin Otter, DLR - Institute of System Dynamics and Control","category":"page"}]
}
