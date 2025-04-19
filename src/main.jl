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
    container = Container(-0.5, -0.5, 1.0, 1.0, (0.2, 0.6, 0.8, 1.0), [], () -> println("Container clicked!"))

    while !GLFW.WindowShouldClose(window)
        # Clear the screen
        ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

        # Get mouse position
        mouse_x, mouse_y = GLFW.GetCursorPos(window)

        # Convert mouse coordinates to normalized device coordinates (NDC)
        mouse_x = (mouse_x / 800) * 2 - 1  # Assuming window width is 800
        mouse_y = -((mouse_y / 600) * 2 - 1)  # Assuming window height is 600

        # Check for mouse clicks
        if GLFW.GetMouseButton(window, GLFW.MOUSE_BUTTON_LEFT) == GLFW.PRESS
            handle_click(container, mouse_x, mouse_y, GLFW.MOUSE_BUTTON_LEFT, GLFW.PRESS)
        end

        # Update the container's color
        container.color = color_state.value

        # Render the container
        render_component(container)

        # Swap buffers and poll events
        GLFW.SwapBuffers(window)
        GLFW.PollEvents()
    end

    GLFW.DestroyWindow(window)
end

main()