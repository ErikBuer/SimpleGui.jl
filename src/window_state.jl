"""
The state of a window, including its size and context.

# Fields

- `width_px`: The width of the window in pixels.
- `height_px`: The height of the window in pixels.
- `handle`: The GLFW window handle.
- `main container`: The main container for the GUI. Primary container for the GUI application.
    This is the main container that holds all other components.
    Its primary purpose is to be a reference for docking and layout calculations.
- `mouse_state`: The current state of the mouse, including its position and button states.
- `projection_matrix`: The projection matrix used for pixel coordinates to NDC conversion.
"""
mutable struct WindowState
    width_px::Integer
    height_px::Integer
    handle::Union{GLFW.Window,Nothing}
    root_view::AbstractView  # Root of the UI tree
    mouse_state::MouseState
    projection_matrix::Mat4{Float32}
end


function handle_events(window_state::WindowState)
    for component in window_state.main_container.children
        # Handle events for the component
        handle_component_events(component, window_state.mouse_state)
    end
end


function framebuffer_size_callback(window_state::WindowState, gl_window, width_px::Integer, height_px::Integer)
    window_state.width_px = width_px
    window_state.height_px = height_px
end

function mouse_button_callback(window_state::WindowState, gl_window, button, action, mods)
    if action == GLFW.PRESS
        window_state.mouse_state.button_state[button] = IsPressed
    elseif action == GLFW.RELEASE
        window_state.mouse_state.button_state[button] = IsReleased
    end
end

"""
    initialize_window(root_view::AbstractView; title::String="SimpleGUI", window_width_px::Integer=1920, window_height_px::Integer=1080)::WindowState

Create and initialize a new `WindowState` instance with default values.

# Arguments

- `title::String`: The name of the window. Default is "SimpleGUI".
- `window_width_px::Integer`: The width of the window in pixels.
- `window_height_px::Integer`: The height of the window in pixels.

# Returns

- `WindowState`: A new instance of `WindowState` with the specified window size and default values for other fields.
"""
function initialize_window(root_view::AbstractView; title::String="SimpleGUI", window_width_px::Integer=1920, window_height_px::Integer=1080)::WindowState
    gl_window = GLFW.Window(name=title, resolution=(window_width_px, window_height_px))
    GLA.set_context!(gl_window)
    GLFW.MakeContextCurrent(gl_window)

    # Enable alpha blending using ModernGL
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    initialize_shaders()

    # Initialize the mouse state
    mouse_state = MouseState(
        Dict(GLFW.MOUSE_BUTTON_LEFT => IsReleased, GLFW.MOUSE_BUTTON_RIGHT => IsReleased),
        0.0,
        0.0
    )

    # Initialize the projection matrix
    projection_matrix = SimpleGui.get_orthographic_matrix(
        0.0f0, Float32(window_width_px), Float32(window_height_px), 0.0f0, -1.0f0, 1.0f0
    )

    window_state = WindowState(window_width_px, window_height_px, gl_window, root_view, mouse_state, projection_matrix)

    _framebuffer_size_callback(gl_window, width_px::Integer, height_px::Integer) = framebuffer_size_callback(window_state, gl_window, width_px, height_px)
    _mouse_button_callback(gl_window, button, action, mods) = mouse_button_callback(window_state, gl_window, button, action, mods)

    # Register the framebuffer size callback with a closure
    GLFW.SetFramebufferSizeCallback(gl_window, _framebuffer_size_callback)
    # Register the mouse button callback with a closure
    GLFW.SetMouseButtonCallback(gl_window, _mouse_button_callback)

    return window_state
end

function update_window_size(window_state::WindowState)
    window_state.width_px, window_state.height_px = GLFW.GetFramebufferSize(window_state.handle)
end

# Update the viewport and projection matrix in the main loop
function update_viewport(window_state::WindowState)
    glViewport(0, 0, window_state.width_px, window_state.height_px)
end