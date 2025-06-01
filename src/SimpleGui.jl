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

include("gui_component.jl")
export AbstractView
export AbstractGuiComponent, register_component
export handle_click, handle_context_menu, handle_dbl_click, handle_mouse_enter, handle_mouse_leave, handle_mouse_move, handle_mouse_out, handle_mouse_over, handle_mouse_down, handle_mouse_up

include("events.jl")
export register_event
export OnClick, OnContextMenu, OnDblClick, OnMouseDown, OnMouseEnter, OnMouseLeave, OnMouseMove, OnMouseOut, OnMouseOver, OnMouseUp

include("gui_component/component_state.jl")
export ComponentState, get_state

include("components.jl")

include("window_state.jl")
export WindowState, initialize_window

include("test_utilitites.jl")

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


function update_projection_matrix(window_state::WindowState)
    window_state.projection_matrix = get_orthographic_matrix(0.0f0, Float32(window_state.width_px), Float32(window_state.height_px), 0.0f0, -1.0f0, 1.0f0)
end


"""
    register_component(component::AbstractGuiComponent)

Register a GUI component to the global list of components.
This function is used to keep track of all components (on the top level) that need to be rendered and updated.
"""
function register_component(window_state::WindowState, component::AbstractGuiComponent)
    push!(window_state.main_container.children, component)
end

"""
    run(window)

Run the main loop for the GUI application.
This function handles the rendering and event processing for the GUI.
"""
function run(window_state::WindowState)

    ModernGL.glDisable(ModernGL.GL_CULL_FACE)
    ModernGL.glDisable(ModernGL.GL_DEPTH_TEST)

    while !GLFW.WindowShouldClose(window_state.handle)
        update_window_size(window_state)

        update_viewport(window_state)
        update_projection_matrix(window_state)

        # Clear the screen
        ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

        # Update mouse position
        #window_state.mouse_state.x, window_state.mouse_state.y = GLFW.GetCursorPos(window_state.handle)

        # Centralized event handling
        # handle_events(window_state)

        # render(window_state.main_container, window_state.projection_matrix::Mat4{Float32})

        # Interpret and render the main container
        #root_layout = apply_layout(window_state.root_view, 0.0, 0.0, window_state.width_px, window_state.height_px)
        # interpret_view(root_layout, window_state.projection_matrix)
        interpret_view(window_state.root_view, 0.0f0, 0.0f0, Float32(window_state.width_px), Float32(window_state.height_px), window_state.projection_matrix)

        # Swap buffers and poll events
        GLFW.SwapBuffers(window_state.handle)
        GLFW.PollEvents()
    end

    # Clean up
    GLFW.DestroyWindow(window_state.handle)
end

end