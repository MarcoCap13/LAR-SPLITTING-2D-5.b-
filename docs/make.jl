using Pkg
pkg"activate .."

using Documenter, LARSplitting2D, DocumenterMarkdown
using DocumenterTools: Themes

makedocs(
    format = Documenter.HTML(
		prettyurls = get(ENV, "CI", nothing) == "true"
	), 
    sitename="LARSplitting2D.jl",
    pages=[
        "Home" => "index.md",
        "Documentazione" => [
            "Studio Preliminare" => "relazione_preliminare.md",
            "Studio Esecutivo" => "relazione_esecutiva.md",
            "Studio Definitivo" => "relazione_definitiva.md",
        ],
        "Docstring" => "docs2d.md",
    ],
    modules=[LARSplitting2D]
)

deploydocs(
    repo="https://github.com/MarcoCap13/LARSplitting2D.git" 
)


