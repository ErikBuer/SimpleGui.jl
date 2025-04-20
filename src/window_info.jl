mutable struct WindowInfo
    width_px::Integer
    height_px::Integer
    handle::Union{GLFW.Window,Nothing}
end

function framebuffer_size_callback(window, width_px, height_px)
    global window_info
    window_info.width_px = width_px
    window_info.height_px = height_px
end

function initialize_window(window_name::String="Simple GUI", resolution::Tuple{Int,Int}=(800, 600))
    window = GLFW.Window(name=window_name, resolution=resolution)
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