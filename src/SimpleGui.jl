module SimpleGui

using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

using GeometryBasics

include("hooks.jl")
export use_state

include("shader.jl")
export initialize_shaders, prog

include("components.jl")


end