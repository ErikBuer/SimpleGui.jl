
"""
Mouse event handling for GUI components.
This module provides functionality to register and handle mouse events for GUI components.


Register funcitons to these events. 
"""
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

function register_event(component::GuiComponent, event::Symbol, listener::Function)
    # Add the listener to the component's event handlers
    component.state.event_handlers[event] = listener

    # Enable event checking for this event
    component.state.enabled_events[event] = true
end

function dispatch_event(component::GuiComponent, event::Symbol, args...)
    state = get_state(component)
    if haskey(state.event_handlers, event)
        handler = state.event_handlers[event]
        # Check the number of arguments the handler accepts
        num_args = length(first(methods(handler)).sig.parameters) - 1  # Subtract 1 for the function itself
        if num_args == 0
            handler()  # Call zero-argument listener
        else
            handler(args...)  # Call listener with arguments
        end
    end
end

function handle_events(mouse_state::MouseState)
    for component in components
        handle_component_events(component, mouse_state)
    end
end

function handle_component_events(component::GuiComponent, mouse_state::MouseState)
    # Iterate through all mouse events
    for event in MouseEvent
        if get(component.state.enabled_events, event, false)
            # Call the appropriate handler for the event
            if event == :on_click
                handle_click(component, mouse_state)
            elseif event == :on_context_menu
                handle_context_menu(component, mouse_state)
            elseif event == :on_dbl_click
                handle_dbl_click(component, mouse_state)
            elseif event == :on_mouse_enter
                handle_mouse_enter(component, mouse_state)
            elseif event == :on_mouse_leave
                handle_mouse_leave(component, mouse_state)
            elseif event == :on_mouse_move
                handle_mouse_move(component, mouse_state)
            elseif event == :on_mouse_out
                handle_mouse_out(component, mouse_state)
            elseif event == :on_mouse_over
                handle_mouse_over(component, mouse_state)
            elseif event == :on_mouse_down
                handle_mouse_down(component, mouse_state)
            elseif event == :on_mouse_up
                handle_mouse_up(component, mouse_state)
            end
        end
    end

    # Recursively handle events for child components
    for child in component.children
        handle_component_events(child, mouse_state)
    end
end