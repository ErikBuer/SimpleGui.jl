using ModernGL, GLAbstraction, GLFW # OpenGL dependencies
const GLA = GLAbstraction


function main()
    window = GLFW.Window(name="EDA.jl", resolution=(800, 600))
    GLA.set_context!(window)

    # Make the window's context current
    GLFW.MakeContextCurrent(window)

    # Loop until the user closes the window
    while !GLFW.WindowShouldClose(window)

        # Render here

        # Swap front and back buffers
        GLFW.SwapBuffers(window)

        # Poll for and process events
        GLFW.PollEvents()
    end

    GLFW.DestroyWindow(window)
end

main()