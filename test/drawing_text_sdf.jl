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

# Define the character and pixel size
char = '?'
pixelsize = 32

# Render the glyph and get its bitmap
bitmap, extent = renderface(font_face, char, pixelsize)

width_px = Float32(extent.advance[1])  # Width
height_px = Float32(extent.advance[2]) # Height

# Convert the bitmap to a binary array for SDF calculation
bitmap_bool = bitmap .> 128
bitmap_bool_matrix = Matrix(bitmap_bool)

# Calculate the SDF matrix
sdf_matrix = SimpleGui.calculate_signed_distance_field(bitmap_bool_matrix)

# Create an OpenGL texture from the SDF matrix
sdf_texture = SimpleGui.create_sdf_texture(sdf_matrix)

# Main rendering loop
while !GLFW.WindowShouldClose(window_state.handle)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Draw the SDF text
    SimpleGui.draw_sdf_text(
        sdf_texture,
        100.0f0, 100.0f0,  # x_px, y_px (Position in pixels)
        width_px, height_px,  # Glyph size
        window_state.projection_matrix,  # Projection matrix
        Vec{4,Float32}(1.0, 1.0, 1.0, 1.0),  # text_color (White color)
        0.05f0  # Smoothing factor
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