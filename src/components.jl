mutable struct ComponentState
    is_hovered::Bool
    is_clicked::Bool
    event_handlers::Dict{Symbol,Function}
end

# Constructor with default values
function ComponentState()
    return ComponentState(false, false, Dict{Symbol,Function}())
end

abstract type GuiComponent end

# Implement get_state for Container
function get_state(component::GuiComponent)::ComponentState
    error("get_state must be implemented by all GuiComponent subtypes")
end

# Generic event dispatcher
function dispatch_event(component::GuiComponent, event::Symbol, args...)
    state = get_state(component)
    if haskey(state.event_handlers, event)
        state.event_handlers[event](args...)
    end
end

const MouseEvent = Symbol[
    :on_click,
    :on_context_menu,
    :on_dbl_click,
    :on_mouse_down,
    :on_mouse_enter,
    :on_mouse_leave,
    :on_mouse_move,
    :on_mouse_out,
    :on_mouse_over,
    :on_mouse_up
]

# Placeholder functions for components
function handle_click(component::GuiComponent, mouse_x::Float64, mouse_y::Float64, button, action)
    error("handle_click is not implemented for $(typeof(component))")
end
function handle_context_menu(component::GuiComponent, mouse_x::Float64, mouse_y::Float64)
    error("handle_context_menu is not implemented for $(typeof(component))")
end
function handle_dbl_click(component::GuiComponent, mouse_x::Float64, mouse_y::Float64)
    error("handle_dbl_click is not implemented for $(typeof(component))")
end
function handle_mouse_enter(component::GuiComponent, mouse_x::Float64, mouse_y::Float64)
    error("handle_mouse_enter is not implemented for $(typeof(component))")
end
function handle_mouse_leave(component::GuiComponent, mouse_x::Float64, mouse_y::Float64)
    error("handle_mouse_leave is not implemented for $(typeof(component))")
end
function handle_mouse_move(component::GuiComponent, mouse_x::Float64, mouse_y::Float64)
    error("handle_mouse_move is not implemented for $(typeof(component))")
end
function handle_mouse_out(component::GuiComponent, mouse_x::Float64, mouse_y::Float64)
    error("handle_mouse_out is not implemented for $(typeof(component))")
end
function handle_mouse_over(component::GuiComponent, mouse_x::Float64, mouse_y::Float64)
    error("handle_mouse_over is not implemented for $(typeof(component))")
end
function handle_mouse_down(component::GuiComponent, mouse_x::Float64, mouse_y::Float64, button)
    error("handle_mouse_down is not implemented for $(typeof(component))")
end
function handle_mouse_up(component::GuiComponent, mouse_x::Float64, mouse_y::Float64, button)
    error("handle_mouse_up is not implemented for $(typeof(component))")
end
function render(component::GuiComponent)
    error("render is not implemented for $(typeof(component))")
end

export handle_click, handle_context_menu, handle_dbl_click, handle_mouse_enter, handle_mouse_leave, handle_mouse_move, handle_mouse_out, handle_mouse_over, handle_mouse_down, handle_mouse_up, render

include("components/container.jl")
export Container