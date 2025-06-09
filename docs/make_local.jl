# Assumes its being run from project root.

using Pkg
Pkg.activate("docs/")
Pkg.develop(path=".")
Pkg.instantiate()

ENV["LOCAL"] = "true"

include("make.jl")