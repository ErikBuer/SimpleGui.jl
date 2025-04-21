module SimpleGui

using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

using GeometryBasics

include("shader.jl")
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


# Create a global instance of the window info
global window_info = WindowInfo(800, 600, nothing)

global mouse_state
mouse_state = MouseState(Dict(GLFW.MOUSE_BUTTON_LEFT => IsReleased, GLFW.MOUSE_BUTTON_RIGHT => IsReleased), 0.0, 0.0)

"""
    global components::Vector{AbstractGuiComponent}

A global vector to hold all registered GUI components.
This is used to keep track of all components (on the top level) that need to be rendered and updated.
"""
global components = AbstractGuiComponent[]


"""
    run(window)

Run the main loop for the GUI application.
This function handles the rendering and event processing for the GUI.
"""
function run(window)
    while !GLFW.WindowShouldClose(window)
        # Clear the screen
        ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

        # Update mouse position
        mouse_x, mouse_y = GLFW.GetCursorPos(window)
        mouse_state.x = (mouse_x / window_info.width_px) * 2 - 1
        mouse_state.y = -((mouse_y / window_info.height_px) * 2 - 1)

        # Centralized event handling
        handle_events(mouse_state)

        # Render all registered components
        for component in components
            render(component)
        end

        # Swap buffers and poll events
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    # Clean up the window
    GLFW.DestroyWindow(window)
end

end