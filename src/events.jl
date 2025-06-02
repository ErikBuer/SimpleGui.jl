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

struct Event
    id::String
    event_type::MouseEvent
end