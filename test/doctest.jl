using Documenter
using SimpleGui

# Run doctests for SimpleGui.jl

DocMeta.setdocmeta!(SimpleGui, :DocTestSetup, :(using SimpleGui); recursive=true)
Documenter.doctest(SimpleGui)