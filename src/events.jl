"""
Mouse event handling for GUI components.
This module provides functionality to register and handle mouse events for GUI components.

Register functions to these events using.
"""
@enum MouseEvent begin
    OnClick
    OnContextMenu
    OnDblClick
    OnMouseDown
    OnMouseEnter
    OnMouseLeave
    OnMouseMove
    OnMouseOut
    OnMouseOver
    OnMouseUp
end

function register_event(component::AbstractGuiComponent, event::MouseEvent, listener::Function)
    # Add the listener to the component's event handlers
    component.state.event_handlers[event] = listener

    # Enable event checking for this event
    component.state.enabled_events[event] = true
end

function dispatch_event(component::AbstractGuiComponent, event::MouseEvent, args...)
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
        if isa(component, ScrollArea)
            # Handle vertical scroll bar events
            if component.vertical_scrollbar.visible
                handle_scroll_interaction(component.vertical_scrollbar, mouse_state)
                handle_scroll_event(component.vertical_scrollbar, component, mouse_state)
            end

            # Handle horizontal scroll bar events
            if component.horizontal_scrollbar.visible
                handle_scroll_interaction(component.horizontal_scrollbar, mouse_state)
                handle_scroll_event(component.horizontal_scrollbar, component, mouse_state)
            end
        end

        # Handle events for the child component
        handle_component_events(component, mouse_state)
    end
end

function handle_component_events(component::AbstractGuiComponent, mouse_state::MouseState)
    # Iterate through all mouse events using `instances(MouseEvent)`
    for event in instances(MouseEvent)
        if get(component.state.enabled_events, event, false)
            # Call the appropriate handler for the event
            if event == OnClick
                handle_click(component, mouse_state)
            elseif event == OnContextMenu
                handle_context_menu(component, mouse_state)
            elseif event == OnDblClick
                handle_dbl_click(component, mouse_state)
            elseif event == OnMouseEnter
                handle_mouse_enter(component, mouse_state)
            elseif event == OnMouseLeave
                handle_mouse_leave(component, mouse_state)
            elseif event == OnMouseMove
                handle_mouse_move(component, mouse_state)
            elseif event == OnMouseOut
                handle_mouse_out(component, mouse_state)
            elseif event == OnMouseOver
                handle_mouse_over(component, mouse_state)
            elseif event == OnMouseDown
                handle_mouse_down(component, mouse_state)
            elseif event == OnMouseUp
                handle_mouse_up(component, mouse_state)
            end
        end
    end

    # Recursively handle events for child components
    for child in component.children
        handle_component_events(child, mouse_state)
    end
end