using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

include("SimpleGui.jl")
using .SimpleGui

"""
Enum representing the state of a mouse button.

- `IsPressed`: The button is currently pressed.
- `IsReleased`: The button is currently released.
"""
@enum ButtonState IsPressed IsReleased

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

function main()
    window = GLFW.Window(name="GUI Playground", resolution=(800, 600))
    GLA.set_context!(window)
    GLFW.MakeContextCurrent(window)

    # Register the mouse button callback
    GLFW.SetMouseButtonCallback(window, mouse_button_callback)

    # Initialize shaders
    initialize_shaders()

    # Initialize the mouse state
    global mouse_state
    mouse_state = MouseState(Dict(GLFW.MOUSE_BUTTON_LEFT => IsReleased, GLFW.MOUSE_BUTTON_RIGHT => IsReleased), 0.0, 0.0)

    # Create a state for the container's color
    color_state, set_color = use_state((0.2, 0.6, 0.8, 1.0))

    # Create a container
    container = Container(-0.5, -0.5, 1.0, 1.0, (0.2, 0.6, 0.8, 1.0))
    container.state.event_handlers[:on_click] = () -> println("Container clicked!")
    container.state.event_handlers[:on_mouse_enter] = () -> println("Mouse entered container!")

    while !GLFW.WindowShouldClose(window)
        # Clear the screen
        ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

        # Update mouse position
        mouse_x, mouse_y = GLFW.GetCursorPos(window)
        mouse_state.x = (mouse_x / 800) * 2 - 1
        mouse_state.y = -((mouse_y / 600) * 2 - 1)

        # Dispatch mouse events
        handle_click(container, mouse_state.x, mouse_state.y, GLFW.MOUSE_BUTTON_LEFT, mouse_state.button_state[GLFW.MOUSE_BUTTON_LEFT] == IsPressed)
        handle_mouse_enter(container, mouse_state.x, mouse_state.y)

        # Render the container
        render(container)

        # Swap buffers and poll events
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    GLFW.DestroyWindow(window)
end

main()