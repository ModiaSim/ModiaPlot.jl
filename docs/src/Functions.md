# Functions

```@meta
CurrentModule = ModiaPlot
```

This chapter documents the exported functions of ModiaPlot.

| Functions                       | Description                                                |
|:--------------------------------|:-----------------------------------------------------------|
| [`plot`](@ref)                  | Plot simulation results in multiple diagrams/figures       |
| [`printResultInfo`](@ref)       | Print info of the signals that are stored in result        |
| [`closeFigure`](@ref)           | Close one figure                                           |
| [`closeAllFigures`](@ref)       | Close all figures                                          |
| [`showFigure`](@ref)            | Show figure in window                   |
| [`saveFigure`](@ref)            | Save figure in png, jpg or bmp format   |


## Interactive Commands

Once a plot window has been created, then the following interactive commands are available:

| Functionality                |  GLMakie                       |
|:-----------------------------|:-------------------------------|
| Zoom                         | Mouse wheel scrolling          |
| Pan                          | Mouse right click and dragging |
| Save in png, jpg, bmp format | [`saveFigure`](@ref)           |


## Plot Functions

```@docs
plot
printResultInfo
closeFigure
closeAllFigures
showFigure
saveFigure
```
