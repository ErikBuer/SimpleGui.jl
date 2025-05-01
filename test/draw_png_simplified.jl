using ModernGL, GLFW, GLAbstraction
const GLA = GLAbstraction

using GeometryBasics
using FileIO, IndirectArrays, ColorTypes, OffsetArrays

mutable struct WindowInfo
    width_px::Integer
    height_px::Integer
    handle::Union{GLFW.Window,Nothing}
end

global window_info = WindowInfo(800, 600, nothing)

function ndc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (dim / 2) * dim_px
end

function px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (px / dim_px) * 2
end

# Initialize the OpenGL context and window
const window = GLFW.Window(name="Example", resolution=(window_info.width_px, window_info.height_px))
GLFW.MakeContextCurrent(window)
GLA.set_context!(window)

# Vertex Shader
const vertex_shader = GLA.vert"""
#version 330 core
layout(location = 0) in vec2 position;
layout(location = 1) in vec4 color;
layout(location = 2) in vec2 texcoord;

out vec4 v_color;
out vec2 v_texcoord;

void main() {
    gl_Position = vec4(position, 0.0, 1.0);
    v_color = color;
    v_texcoord = texcoord;
}
"""

# Fragment Shader
const fragment_shader = GLA.frag"""
#version 330 core
in vec4 v_color;
in vec2 v_texcoord;

out vec4 FragColor;

uniform sampler2D image;
uniform bool use_texture;

void main() {
    if (use_texture) {
        FragColor = texture(image, v_texcoord);
    } else {
        FragColor = v_color;
    }
}
"""

# Compile the shader program
program = GLA.Program(vertex_shader, fragment_shader)

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

function draw_image(texture::GLAbstraction.Texture, x::AbstractFloat, y::AbstractFloat; scale::AbstractFloat=1.0)
    global window_info

    # Get the image size from the texture
    width_px, height_px = GLA.size(texture)

    # Convert image size to normalized device coordinates (NDC)
    width_ndc = px_to_ndc(width_px * scale, window_info.width_px)
    height_ndc = px_to_ndc(height_px * scale, window_info.height_px)

    # Define rectangle vertices
    positions = [
        Point2f(x, y),                          # Bottom-left
        Point2f(x + width_ndc, y),              # Bottom-right
        Point2f(x, y + height_ndc),             # Top-left
        Point2f(x + width_ndc, y + height_ndc)  # Top-right
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
            position=positions,
            texcoord=texturecoordinates
        ),
        indices
    )

    # Bind the shader program
    GLA.bind(program)

    # Set the `use_texture` uniform to true
    GLA.gluniform(program, :use_texture, true)

    # Bind the texture to the shader's sampler2D uniform
    GLA.gluniform(program, :image, 0, texture)

    # Bind the VAO and draw the rectangle
    GLA.bind(vao)
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(program)
end

file_path = "test/images/logo.png"

# Load the texture from an image file
tex = load_texture(file_path)  # Replace with the path to your image file

# Set the clear color
glClearColor(0, 0, 0, 1)

# Main rendering loop
while !GLFW.WindowShouldClose(window)
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

    # Draw the image at position (0.0, 0.0)
    draw_image(tex, 0.0f0, 0.0f0)

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