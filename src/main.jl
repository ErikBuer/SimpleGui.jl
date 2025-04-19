using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction

include("SimpleGui.jl")
using .SimpleGui

function main()
    window = GLFW.Window(name="GUI Playground", resolution=(800, 600))
    GLA.set_context!(window)
    GLFW.MakeContextCurrent(window)

    # Initialize shaders
    initialize_shaders()

    # Create a state for the container's color
    color_state, set_color = use_state((0.2, 0.6, 0.8, 1.0))

    # Create a container
    container = Container(-0.5, -0.5, 1.0, 1.0, (0.2, 0.6, 0.8, 1.0))
    container.event_handlers[:on_click] = () -> println("Container clicked!")
    container.event_handlers[:on_mouse_enter] = () -> println("Mouse entered container!")
    container.event_handlers[:on_mouse_leave] = () -> println("Mouse left container!")

    while !GLFW.WindowShouldClose(window)
        # Clear the screen
        ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

        # Get mouse position
        mouse_x, mouse_y = GLFW.GetCursorPos(window)
        mouse_x = (mouse_x / 800) * 2 - 1
        mouse_y = -((mouse_y / 600) * 2 - 1)

        # Dispatch mouse events
        handle_click(container, mouse_x, mouse_y, GLFW.MOUSE_BUTTON_LEFT, GLFW.PRESS)
        handle_mouse_enter(container, mouse_x, mouse_y)
        handle_mouse_leave(container, mouse_x, mouse_y)

        # Render the container
        render(container)

        # Swap buffers and poll events
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    GLFW.DestroyWindow(window)
end

main()