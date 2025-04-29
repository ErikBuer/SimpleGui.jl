using ModernGL, GeometryBasics, GLAbstraction, GLFW
const GLA = GLAbstraction

# Vertex and Fragment Shaders
const vertex_shader = GLA.vert"""
#version 330 core
layout(location = 0) in vec2 position;
layout(location = 1) in vec4 color;

out vec4 v_color;

void main() {
    gl_Position = vec4(position, 0.0, 1.0);
    v_color = color;
}
"""

const fragment_shader = GLA.frag"""
#version 330 core
    in vec4 v_color;
    out vec4 FragColor;

    void main() {
        FragColor = v_color;
    }
"""


# Global variable for the shader program
const prog = Ref{GLA.Program}()

# Initialize the shader program (must be called after OpenGL context is created)
function initialize_shaders()
    prog[] = GLA.Program(vertex_shader, fragment_shader)
end

function ndc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (dim / 2) * dim_px
end

function px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (px / dim_px) * 2
end


function draw_closed_lines(vertices::Vector{Point2f}, color_rgba::Vec4{<:AbstractFloat})
    # Generate a uniform color array for all vertices
    colors = Vec{4,Float32}[color_rgba for _ in 1:length(vertices)]

    # Generate buffers for positions and colors
    buffers = GLA.generate_buffers(prog[], position=vertices, color=colors)

    # Create a Vertex Array Object (VAO) with the primitive type GL_LINE_LOOP
    vao = GLA.VertexArray(buffers, GL_LINE_LOOP)

    # Bind the shader program and VAO
    GLA.bind(prog[])
    GLA.bind(vao)

    # Draw the vertices using the VAO
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(prog[])
end

# Initialize the OpenGL context and window
window_width_px = 800
window_height_px = 600
window = GLFW.Window(name="Drawing lines", resolution=(window_width_px, window_height_px))
GLA.set_context!(window)
GLFW.MakeContextCurrent(window)

# Initialize the shader program
initialize_shaders()

# The vertices of our rectangle
vertices = Point2f[(-0.5, 0.5), (0.5, 0.5), (0.5, -0.5), (-0.5, -0.5)]

# Uniform color (e.g., red)
rgba::Vec4{Float32} = [1.0f0, 1.0f0, 1.0f0, 1.0f0]


# Main rendering loop
glClearColor(0, 0, 0, 0)
while !GLFW.WindowShouldClose(window)
    glClear(GL_COLOR_BUFFER_BIT)

    # Draw the rectangle border using the reusable function
    draw_closed_lines(vertices, rgba)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
    if GLFW.GetKey(window, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window, true)
    end
end

GLFW.DestroyWindow(window)