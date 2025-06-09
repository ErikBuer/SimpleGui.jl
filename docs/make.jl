push!(LOAD_PATH, "../src/")

using Documenter

# Running `julia --project docs/make.jl` can be very slow locally.
# To speed it up during development, one can use make_local.jl instead.
# The code below checks wether its being called from make_local.jl or not.
const LOCAL = get(ENV, "LOCAL", "false") == "true"

if LOCAL
    include("../src/SimpleGui.jl")
    using .SimpleGui
else
    using SimpleGui
    ENV["GKSwstype"] = "100"
end

DocMeta.setdocmeta!(SimpleGui, :DocTestSetup, :(using SimpleGui); recursive=true)


makedocs(
    modules=[SimpleGui],
    format=Documenter.HTML(),
    sitename="SimpleGui.jl",
    pages=Any[
        "index.md",
        "Components"=>Any[
            "Components/slider.md",
        ],
        "api_reference.md",
    ],
    doctest=true,
)

deploydocs(
    repo="github.com/ErikBuer/SimpleGui.jl.git",
    push_preview=true,
)