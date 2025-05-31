using ModernGL, GLFW, GLAbstraction
const GLA = GLAbstraction
using FreeTypeAbstraction

using GeometryBasics
using FileIO, IndirectArrays, ColorTypes, OffsetArrays

using SimpleGui

# Initialize the window
window_state = initialize_window("Simple GUI Example", 1920, 1080)

# Load a font using FreeTypeAbstraction
font_face = findfont("arial")
if font_face === nothing
    error("Font not found!")
end

# Main rendering loop
text = "Hello, World!"
pixelsize = 64  # Adjust pixel size for the text

while !GLFW.WindowShouldClose(window_state.handle)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Draw the text
    SimpleGui.draw_text(
        font_face,
        text,
        100.0f0, 100.0f0,                   # x_px, y_px (Position in pixels)
        pixelsize,                          # Pixel size for the font
        window_state.projection_matrix,     # Projection matrix
    )

    # Swap buffers and poll events
    GLFW.SwapBuffers(window_state.handle)
    GLFW.PollEvents()

    # Exit on ESC key press
    if GLFW.GetKey(window_state.handle, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window_state.handle, true)
    end
end

# Destroy the window
GLFW.DestroyWindow(window_state.handle)