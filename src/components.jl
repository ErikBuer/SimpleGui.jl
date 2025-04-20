abstract type GuiComponent end

include("components/component_state.jl")
include("components/utilities.jl")

include("components/layout.jl")
export Alignment, AlignmentType, AlignCenter, AlignLeft, AlignRight, AlignTop, AlignBottom


"""    register_component(component::GuiComponent)

Register a GUI component to the global list of components.
This function is used to keep track of all components (on the top level) that need to be rendered and updated.
"""
function register_component(component::GuiComponent)
    push!(components, component)
end



# Placeholder functions for components
function handle_click(component::GuiComponent, mouse_state::MouseState)
    error("handle_click is not implemented for $(typeof(component))")
end
function handle_context_menu(component::GuiComponent, mouse_state::MouseState)
    error("handle_context_menu is not implemented for $(typeof(component))")
end
function handle_dbl_click(component::GuiComponent, mouse_state::MouseState)
    error("handle_dbl_click is not implemented for $(typeof(component))")
end
function handle_mouse_enter(component::GuiComponent, mouse_state::MouseState)
    error("handle_mouse_enter is not implemented for $(typeof(component))")
end
function handle_mouse_leave(component::GuiComponent, mouse_state::MouseState)
    error("handle_mouse_leave is not implemented for $(typeof(component))")
end
function handle_mouse_move(component::GuiComponent, mouse_state::MouseState)
    error("handle_mouse_move is not implemented for $(typeof(component))")
end
function handle_mouse_out(component::GuiComponent, mouse_state::MouseState)
    error("handle_mouse_out is not implemented for $(typeof(component))")
end
function handle_mouse_over(component::GuiComponent, mouse_state::MouseState)
    error("handle_mouse_over is not implemented for $(typeof(component))")
end
function handle_mouse_down(component::GuiComponent, mouse_state::MouseState)
    error("handle_mouse_down is not implemented for $(typeof(component))")
end
function handle_mouse_up(component::GuiComponent, mouse_state::MouseState)
    error("handle_mouse_up is not implemented for $(typeof(component))")
end
function render(component::GuiComponent)
    error("render is not implemented for $(typeof(component))")
end

include("components/container.jl")
export Container