using ModernGL, GLFW, GLAbstraction
const GLA = GLAbstraction

using SimpleGui

using GeometryBasics
using FileIO, IndirectArrays, ColorTypes, OffsetArrays


window_state = initialize_window("Simple GUI Example", 1920, 1080)

file_path = "test/images/logo.png"

# Load the texture from an image file
tex = SimpleGui.load_texture(file_path)  # Replace with the path to your image file

# Set the clear color
glClearColor(0, 0, 0, 1)

# Main rendering loop
while !GLFW.WindowShouldClose(window_state.handle)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Draw the image at position (0.0, 0.0)
    SimpleGui.draw_image(tex, 0.0, 0.0, window_state.projection_matrix, scale=0.2f0)

    # Swap buffers and poll events
    GLFW.SwapBuffers(window_state.handle)
    GLFW.PollEvents()

    # Exit on ESC key press
    if GLFW.GetKey(window_state.handle, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window_state.handle, true)
    end
end

# Destroy the window_state
GLFW.DestroyWindow(window_state.handle)