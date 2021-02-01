using Documenter, ModiaPlot

makedocs(
  #modules  = [ModiaPlot],
  sitename = "ModiaPlot",
  authors  = "Martin Otter (DLR-SR)",
  format = Documenter.HTML(prettyurls = false),
  pages    = [
     "Home"      => "index.md",
	 "Functions" => "Functions.md",
  	 "Internal"  => "Internal.md",
  ]
)
