# Internal

```@meta
CurrentModule = ModiaPlot
```

This chapter documents the functions that can be specially defined for own
result data structures.

| Functions                       | Description                                                |
|:--------------------------------|:-----------------------------------------------------------|
| [`hasSignal`](@ref)             | Returns true if signal is available in result              |
| [`getRawSignal`](@ref)          | Returns the raw signal from result                         |
| [`getNames`](@ref)              | Return a vector of the names that are present in result    |
| [`getDefaultHeading`](@ref)     | Return default heading                                     |
| [`getSignalInfo`](@ref)         | Return information about a signal                          |


## Access Result

```@docs
hasSignal
getRawSignal
getNames
getDefaultHeading
getSignalInfo
```
