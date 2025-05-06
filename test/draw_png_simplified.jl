using ModernGL, GLFW, GLAbstraction
const GLA = GLAbstraction

using SimpleGui

using GeometryBasics
using FileIO, IndirectArrays, ColorTypes, OffsetArrays


window = initialize_window("Simple GUI Example", (1920, 1080))
GLFW.MakeContextCurrent(window)
GLA.set_context!(window)


# Function to load a texture from an image file
function load_texture(file_path::String)::GLAbstraction.Texture
    # Load the image using FileIO
    img = FileIO.load(file_path)  # Returns a Matrix or IndirectArray

    # If the image is an IndirectArray, materialize it into a standard array
    if img isa IndirectArrays.IndirectArray
        @debug("Materializing IndirectArray into a standard array...")
        img = img.values[img.index]
    end

    # Transpose the image to match OpenGL's coordinate system
    img = permutedims(img)  # Swap dimensions 1 and 2 for proper orientation

    # Create a GLAbstraction texture
    texture = GLA.Texture(img; minfilter=:linear, magfilter=:linear, x_repeat=:clamp_to_edge, y_repeat=:clamp_to_edge)

    return texture
end

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