using Documenter
using Element

# Run doctests for Element.jl

DocMeta.setdocmeta!(Element, :DocTestSetup, :(using Element); recursive=true)
Documenter.doctest(Element)