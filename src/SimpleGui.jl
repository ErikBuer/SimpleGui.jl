module SimpleGui

using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

using GeometryBasics, ColorTypes    # Additional rendering dependencies

include("shaders.jl")
export initialize_shaders, prog

include("mouse.jl")
export mouse_state, mouse_button_callback, ButtonState, IsPressed, IsReleased, MouseState

include("window_info.jl")
export initialize_window

include("hooks.jl")
export use_state

include("gui_component.jl")
export AbstractGuiComponent, register_component
export handle_click, handle_context_menu, handle_dbl_click, handle_mouse_enter, handle_mouse_leave, handle_mouse_move, handle_mouse_out, handle_mouse_over, handle_mouse_down, handle_mouse_up

include("events.jl")
export register_event
export OnClick, OnContextMenu, OnDblClick, OnMouseDown, OnMouseEnter, OnMouseLeave, OnMouseMove, OnMouseOut, OnMouseOver, OnMouseUp

include("gui_component/component_state.jl")
export ComponentState, get_state

include("components.jl")

include("test_utilitites.jl")

"""
Primary container for the GUI application.

This is the main container that holds all other components.

Its primary purpose is to be a reference for docking and layout calculations.
"""
global main_container = Container()
main_container.layout.padding_px = 0.0
set_color(main_container, ColorTypes.RGBA(0.0, 1.0, 0.0, 1.0))  # TODO make transparent

"""
    register_component(component::AbstractGuiComponent)

Register a GUI component to the global list of components.
This function is used to keep track of all components (on the top level) that need to be rendered and updated.
"""
function register_component(component::AbstractGuiComponent)
    push!(main_container.children, component)
end


# Create a global instance of the window info
global window_info = WindowInfo(800, 600, nothing)

global mouse_state
mouse_state = MouseState(Dict(GLFW.MOUSE_BUTTON_LEFT => IsReleased, GLFW.MOUSE_BUTTON_RIGHT => IsReleased), 0.0, 0.0)




# Update the viewport and projection matrix in the main loop
function update_viewport()
    global window_info
    glViewport(0, 0, window_info.width_px, window_info.height_px)
end


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


function update_projection_matrix()
    global window_info
    global projection_matrix
    projection_matrix = get_orthographic_matrix(0.0f0, Float32(window_info.width_px), Float32(window_info.height_px), 0.0f0, -1.0f0, 1.0f0)
end


"""
    run(window)

Run the main loop for the GUI application.
This function handles the rendering and event processing for the GUI.
"""
function run(window)

    ModernGL.glDisable(ModernGL.GL_CULL_FACE)
    ModernGL.glDisable(ModernGL.GL_DEPTH_TEST)

    while !GLFW.WindowShouldClose(window)
        update_window_size(window)

        update_viewport()
        update_projection_matrix()

        # Clear the screen
        ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

        # Update mouse position
        mouse_state.x, mouse_state.y = GLFW.GetCursorPos(window)

        # Centralized event handling
        handle_events(mouse_state)

        render(main_container)

        # Swap buffers and poll events
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    # Clean up the window
    GLFW.DestroyWindow(window)
end

end