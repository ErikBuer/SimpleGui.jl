using ModernGL, GLFW, GLAbstraction
import GLAbstraction: N0f8
const GLA = GLAbstraction

using ColorTypes, GeometryBasics
using FileIO

# Initialize the OpenGL context and window
const window = GLFW.Window(name="Example")
GLFW.MakeContextCurrent(window)
GLA.set_context!(window)

# Vertex Shader
const vert = GLA.vert"""
#version 330 core

in vec2 vertices;
in vec2 texturecoordinates; // must be this name, because collect_for_gl assumes them

out vec2 f_uv;
void main() {
    f_uv = texturecoordinates;
    gl_Position = vec4(vertices, 0.0, 1.0);
}
"""

# Fragment Shader
const frag = GLA.frag"""
#version 330 core

out vec4 outColor;
uniform sampler2D image;
in vec2 f_uv;

void main() {
    outColor = texture(image, f_uv);
}
"""

# Compile the shader program
program = GLA.Program(vert, frag)

# Function to load a texture from an image file
function load_texture(file_path::String)::GLAbstraction.Texture
    # Load the image using FileIO
    img = FileIO.load(file_path)  # Returns a Matrix{RGBA{N0f8}}
    # Transpose the image to match OpenGL's coordinate system and materialize it as a proper array
    img = permutedims(img)  # Swap dimensions 1 and 2 for a proper transpose

    # Debug: Check the image properties
    println("Image size: ", size(img))
    println("Image type: ", typeof(img))


    # Create a GLAbstraction texture
    texture = GLA.Texture(img; minfilter=:linear, magfilter=:linear, x_repeat=:clamp_to_edge, y_repeat=:clamp_to_edge)

    return texture
end

file_path = "test/images/logo.png"

# Load the texture from an image file
tex = load_texture(file_path)  # Replace with the path to your image file

function draw_image(tex::GLAbstraction.Texture, program::GLAbstraction.Program)
    # Define rectangle vertices
    vertices = [
        Point2f(-1, -1),  # Bottom-left
        Point2f(1, -1),   # Bottom-right
        Point2f(-1, 1),   # Top-left
        Point2f(1, 1)     # Top-right
    ]

    # Define texture coordinates
    texturecoordinates = [
        Vec{2,Float32}(0.0f0, 1.0f0),  # Bottom-left
        Vec{2,Float32}(1.0f0, 1.0f0),  # Bottom-right
        Vec{2,Float32}(0.0f0, 0.0f0),  # Top-left
        Vec{2,Float32}(1.0f0, 0.0f0)   # Top-right
    ]

    # Define indices for two triangles forming the rectangle
    indices = TriangleFace{OffsetInteger{-1,UInt32}}[
        TriangleFace{OffsetInteger{-1,UInt32}}((OffsetInteger{-1,UInt32}(1), OffsetInteger{-1,UInt32}(2), OffsetInteger{-1,UInt32}(4))),  # First triangle
        TriangleFace{OffsetInteger{-1,UInt32}}((OffsetInteger{-1,UInt32}(4), OffsetInteger{-1,UInt32}(3), OffsetInteger{-1,UInt32}(1)))   # Second triangle
    ]

    # Generate buffers and create a Vertex Array Object (VAO)
    vao = GLA.VertexArray(
        GLA.generate_buffers(
            program,
            vertices=vertices,
            texturecoordinates=texturecoordinates
        ),
        indices
    )

    # Bind the shader program
    GLA.bind(program)

    # Bind the texture to the shader's sampler2D uniform
    GLA.gluniform(program, :image, 0, tex)

    # Bind the VAO and draw the rectangle
    GLA.bind(vao)
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(program)
end

# Set the clear color
glClearColor(0, 0, 0, 1)

# Main rendering loop
while !GLFW.WindowShouldClose(window)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    draw_image(tex, program)

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