module SimpleGui

using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

using GeometryBasics

include("hooks.jl")
export use_state

include("shader.jl")
export initialize_shaders, prog

include("components.jl")


mutable struct WindowInfo
    width_px::Integer
    height_px::Integer
    handle::Union{GLFW.Window,Nothing}
end

# Create a global instance of the window info
global window_info = WindowInfo(800, 600, nothing)

function framebuffer_size_callback(window, width_px, height_px)
    global window_info
    window_info.width_px = width_px
    window_info.height_px = height_px
end

function initialize_window(window_name::String="Simple GUI")
    window = GLFW.Window(name=window_name, resolution=(800, 600))
    GLA.set_context!(window)
    GLFW.MakeContextCurrent(window)

    # Update the global window info
    global window_info
    window_info.handle = window
    window_info.width_px, window_info.height_px = GLFW.GetFramebufferSize(window)

    # Register the framebuffer size callback
    GLFW.SetFramebufferSizeCallback(window, framebuffer_size_callback)

    return window
end

export initialize_window


end