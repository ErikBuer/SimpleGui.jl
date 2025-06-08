"""
Enum representing the different mouse buttons.

- `LeftButton`: The left mouse button.
- `RightButton`: The right mouse button.
- `MiddleButton`: The middle mouse button (scroll button).
"""
@enum MouseButton LeftButton RightButton MiddleButton

"""
Enum representing the state of a mouse button.

- `IsReleased`: The button is currently released.
- `IsPressed`: The button is currently pressed.
"""
@enum ButtonState IsReleased IsPressed


# Shared state for mouse input
mutable struct MouseState
    button_state::Dict{MouseButton,ButtonState}  # Tracks the state of each button
    x::Float64                                    # Mouse X position
    y::Float64                                    # Mouse Y position
    last_click_time::Float64                      # Time of the last click
    last_click_position::Tuple{Float64,Float64}  # Position of the last click
end

function mouse_button_callback(gl_window, button::GLFW.MouseButton, action::GLFW.Action, mods, mouse_state::MouseState)
    # Map GLFW.MouseButton to MouseButton
    mapped_button = if button == GLFW.MOUSE_BUTTON_LEFT
        LeftButton
    elseif button == GLFW.MOUSE_BUTTON_RIGHT
        RightButton
    elseif button == GLFW.MOUSE_BUTTON_MIDDLE
        MiddleButton
    else
        return  # Ignore unsupported buttons
    end

    if action == GLFW.PRESS || action == GLFW.RELEASE
        mouse_state.button_state[mapped_button] = (action == GLFW.PRESS) ? IsPressed : IsReleased
        mouse_state.last_click_position = Tuple(GLFW.GetCursorPos(gl_window))  # Convert NamedTuple to Tuple
        mouse_state.last_click_time = time()  # Use Julia's `time()` function
    end

    #TODO handle double-click detection
end