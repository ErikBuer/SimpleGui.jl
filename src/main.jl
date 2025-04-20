using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

include("SimpleGui.jl")
using .SimpleGui


function main()
    window = initialize_window()
    GLA.set_context!(window)
    GLFW.MakeContextCurrent(window)

    # Register the mouse button callback
    GLFW.SetMouseButtonCallback(window, mouse_button_callback)

    # Initialize shaders
    SimpleGui.initialize_shaders()

    # Create a container
    container = Container(-0.5, -0.5, 1.0, 1.0)
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