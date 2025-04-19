abstract type GuiComponent end

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

# Generic event dispatcher
function dispatch_event(component::GuiComponent, event::Symbol, args...)
    if haskey(component.event_handlers, event)
        component.event_handlers[event](args...)
    end
end

# Placeholder functions for components
function handle_click(component::GuiComponent, mouse_x::Float64, mouse_y::Float64, button, action) end
function handle_context_menu(component::GuiComponent, mouse_x::Float64, mouse_y::Float64) end
function handle_dbl_click(component::GuiComponent, mouse_x::Float64, mouse_y::Float64) end
function handle_mouse_enter(component::GuiComponent, mouse_x::Float64, mouse_y::Float64) end
function handle_mouse_leave(component::GuiComponent, mouse_x::Float64, mouse_y::Float64) end
function handle_mouse_move(component::GuiComponent, mouse_x::Float64, mouse_y::Float64) end
function handle_mouse_out(component::GuiComponent, mouse_x::Float64, mouse_y::Float64) end
function handle_mouse_over(component::GuiComponent, mouse_x::Float64, mouse_y::Float64) end
function handle_mouse_down(component::GuiComponent, mouse_x::Float64, mouse_y::Float64, button) end
function handle_mouse_up(component::GuiComponent, mouse_x::Float64, mouse_y::Float64, button) end
function render(component::GuiComponent) end

export handle_click, handle_context_menu, handle_dbl_click, handle_mouse_enter, handle_mouse_leave, handle_mouse_move, handle_mouse_out, handle_mouse_over, handle_mouse_down, handle_mouse_up, render

include("components/container.jl")
export Container