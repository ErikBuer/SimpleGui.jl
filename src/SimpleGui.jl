module SimpleGui

using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

using GeometryBasics

include("hooks.jl")
export use_state

include("shader.jl")
export initialize_shaders, prog

abstract type GuiComponent end
const MouseEvent = Symbol[:on_click, :on_context_menu, :on_dbl_click, :on_mouse_down, :on_mouse_enter, :on_mouse_leave, :on_mouse_move, :on_mouse_out, :on_mouse_over, :on_mouse_up]

include("components/container.jl")
export Container, handle_click, render_component

end