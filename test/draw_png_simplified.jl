using ModernGL, GLFW, GLAbstraction
const GLA = GLAbstraction

using SimpleGui

using GeometryBasics
using FileIO, IndirectArrays, ColorTypes, OffsetArrays


window = initialize_window("Simple GUI Example", (1920, 1080))
GLFW.MakeContextCurrent(window)
GLA.set_context!(window)

file_path = "test/images/logo.png"

# Load the texture from an image file
tex = SimpleGui.load_texture(file_path)  # Replace with the path to your image file

# Set the clear color
glClearColor(0, 0, 0, 1)

# Main rendering loop
while !GLFW.WindowShouldClose(window)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Draw the image at position (0.0, 0.0)
    SimpleGui.draw_image(tex, 0.0, 0.0, scale=0.2f0)

    # Swap buffers and poll events
    GLFW.SwapBuffers(window)
    GLFW.PollEvents()

    # Exit on ESC key press
    if GLFW.GetKey(window, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window, true)
    end
end

# Destroy the window
GLFW.DestroyWindow(window)