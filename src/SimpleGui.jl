module SimpleGui

using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

using GeometryBasics

include("hooks.jl")
export use_state

include("shader.jl")
export initialize_shaders, prog

include("mouse.jl")
export mouse_state, mouse_button_callback, ButtonState, IsPressed, IsReleased, MouseState

include("window_info.jl")
export initialize_window

include("components.jl")
export handle_click, handle_context_menu, handle_dbl_click, handle_mouse_enter, handle_mouse_leave, handle_mouse_move, handle_mouse_out, handle_mouse_over, handle_mouse_down, handle_mouse_up, render



# Create a global instance of the window info
global window_info = WindowInfo(800, 600, nothing)

global mouse_state
mouse_state = MouseState(Dict(GLFW.MOUSE_BUTTON_LEFT => IsReleased, GLFW.MOUSE_BUTTON_RIGHT => IsReleased), 0.0, 0.0)


end