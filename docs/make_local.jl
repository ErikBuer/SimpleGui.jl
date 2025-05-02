# Assumes its being run from project root.

using Pkg
Pkg.activate("docs/")
Pkg.instantiate()

Pkg.develop(path=".")

ENV["LOCAL"] = "true"

include("make.jl")