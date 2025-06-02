module SimpleGui

using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction
using FreeTypeAbstraction # Font rendering dependencies

using GeometryBasics, ColorTypes    # Additional rendering dependencies

include("shaders.jl")
export initialize_shaders, prog

include("mouse.jl")
export mouse_state, mouse_button_callback, ButtonState, IsPressed, IsReleased, MouseState

include("hooks.jl")
export use_state

include("events.jl")
export OnClick, OnContextMenu, OnDblClick, OnMouseDown, OnMouseEnter, OnMouseLeave, OnMouseMove, OnMouseOut, OnMouseOver, OnMouseUp

include("gui_component.jl")
export AbstractView
export AbstractGuiComponent, register_component
export handle_click, handle_context_menu, handle_dbl_click, handle_mouse_enter, handle_mouse_leave, handle_mouse_move, handle_mouse_out, handle_mouse_over, handle_mouse_down, handle_mouse_up

include("components.jl")

include("interaction_state.jl")

# include("test_utilitites.jl") #TODO converto to new functional structure

include("text_processing.jl")


"""
    get_orthographic_matrix(left::T, right::T, bottom::T, top::T, near::T, far::T)::Matrix{T} where {T<:Real}

Create an orthographic projection matrix.
"""
function get_orthographic_matrix(left::T, right::T, bottom::T, top::T, near::T, far::T)::Mat4{Float32} where {T<:Real}
    orthographic_matrix = [
        2.0/(right-left) 0.0 0.0 -(right + left)/(right-left)
        0.0 2.0/(top-bottom) 0.0 -(top + bottom)/(top-bottom)
        0.0 0.0 -2.0/(far-near) -(far + near)/(far-near)
        0.0 0.0 0.0 1.0
    ]

    return Float32.(Mat4(orthographic_matrix))
end

function get_identity_matrix()
    return Float32.(Mat4(
        1.0, 0.0, 0.0, 0.0,
        0.0, 1.0, 0.0, 0.0,
        0.0, 0.0, 1.0, 0.0,
        0.0, 0.0, 0.0, 1.0,
    ))
end


"""
    run(window)

Run the main loop for the GUI application.
This function handles the rendering and event processing for the GUI.
"""
function run(root_view::AbstractView; title::String="SimpleGUI", window_width_px::Integer=1920, window_height_px::Integer=1080)
    # Initialize the GLFW window
    gl_window = GLFW.Window(name=title, resolution=(window_width_px, window_height_px))
    GLA.set_context!(gl_window)
    GLFW.MakeContextCurrent(gl_window)

    # Enable alpha blending
    glEnable(GL_BLEND)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)

    initialize_shaders()

    # Initialize local states
    mouse_state = MouseState(
        Dict(GLFW.MOUSE_BUTTON_LEFT => IsReleased, GLFW.MOUSE_BUTTON_RIGHT => IsReleased),
        0.0,
        0.0
    )
    #interaction_state = InteractionState(nothing, nothing, nothing)
    projection_matrix = get_orthographic_matrix(0.0f0, Float32(window_width_px), Float32(window_height_px), 0.0f0, -1.0f0, 1.0f0)

    # Main loop
    while !GLFW.WindowShouldClose(gl_window)
        # Update window size
        width_px, height_px = GLFW.GetFramebufferSize(gl_window)

        # Update viewport and projection matrix
        glViewport(0, 0, width_px, height_px)
        projection_matrix = get_orthographic_matrix(0.0f0, Float32(width_px), Float32(height_px), 0.0f0, -1.0f0, 1.0f0)

        # Clear the screen
        ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

        # Update mouse position
        mouse_x, mouse_y = GLFW.GetCursorPos(gl_window)
        mouse_state = MouseState(mouse_state.button_state, mouse_x, mouse_y)

        # Generate and process events
        #interaction_state = update_interaction_state(root_view, mouse_state, 0.0f0, 0.0f0, Float32(width_px), Float32(height_px))
        #events = generate_events(interaction_state)
        #process_events(events, root_view)

        # Render the UI
        interpret_view(root_view, 0.0f0, 0.0f0, Float32(width_px), Float32(height_px), projection_matrix)

        # Swap buffers and poll events
        GLFW.SwapBuffers(gl_window)
        GLFW.PollEvents()
    end

    # Clean up
    GLFW.DestroyWindow(gl_window)
end

end