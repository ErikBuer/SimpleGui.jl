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

function initialize_window(window_name::String="Simple GUI", resolution::Tuple{Int,Int}=(400, 300))
    window = GLFW.Window(name=window_name, resolution=resolution)
    GLA.set_context!(window)
    GLFW.MakeContextCurrent(window)

    # Update the global window info
    global window_info
    window_info.handle = window
    window_info.width_px, window_info.height_px = GLFW.GetFramebufferSize(window)

    # Register the framebuffer size callback
    GLFW.SetFramebufferSizeCallback(window, framebuffer_size_callback)

    # Register the mouse button callback
    GLFW.SetMouseButtonCallback(window, mouse_button_callback)

    initialize_shaders()

    update_projection_matrix()

    return window
end

function update_window_size(window)
    global window_info
    window_info.width_px, window_info.height_px = GLFW.GetFramebufferSize(window)

    global main_container
    main_container.width = window_info.width_px
    main_container.height = window_info.height_px
end