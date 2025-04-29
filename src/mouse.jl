"""
Enum representing the different mouse buttons.

- `LeftButton`: The left mouse button.
- `RightButton`: The right mouse button.
- `MiddleButton`: The middle mouse button (scroll button).
"""
@enum MouseButton LeftButton RightButton MiddleButton   # TODO replace GLFW.MouseButton with this enum

"""
Enum representing the state of a mouse button.

- `IsReleased`: The button is currently released.
- `IsPressed`: The button is currently pressed.
"""
@enum ButtonState IsReleased IsPressed

# Declare mouse_state as a global variable
global mouse_state

function mouse_button_callback(window, button, action, mods)
    if action == GLFW.PRESS
        mouse_state.button_state[button] = IsPressed
    elseif action == GLFW.RELEASE
        mouse_state.button_state[button] = IsReleased
    end
end

# Shared state for mouse input
mutable struct MouseState
    button_state::Dict{GLFW.MouseButton,ButtonState}  # Tracks the state of each button
    x::Float64                     # Mouse X position
    y::Float64                     # Mouse Y position
end