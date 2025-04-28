using ModernGL, GeometryBasics, GLAbstraction, GLFW

function ndc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (dim / 2) * dim_px
end

function px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (px / dim_px) * 2
end


function draw_closed_lines(vertices::Vector{Point2f}, colors::Vector{Vec{4,Float32}}, shader_program::GLuint)
    # Bind the shader program
    glUseProgram(shader_program)

    # Generate a Vertex Array Object (VAO)
    vao = Ref(GLuint(0))
    glGenVertexArrays(1, vao)
    glBindVertexArray(vao[])

    # Generate a Vertex Buffer Object (VBO) for positions
    vbo_positions = Ref(GLuint(0))
    glGenBuffers(1, vbo_positions)
    glBindBuffer(GL_ARRAY_BUFFER, vbo_positions[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), pointer(vertices), GL_STATIC_DRAW)

    # Link vertex position data to the shader's position attribute
    pos_attribute = glGetAttribLocation(shader_program, "position")
    glVertexAttribPointer(pos_attribute, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
    glEnableVertexAttribArray(pos_attribute)

    # Generate a Vertex Buffer Object (VBO) for colors
    vbo_colors = Ref(GLuint(0))
    glGenBuffers(1, vbo_colors)
    glBindBuffer(GL_ARRAY_BUFFER, vbo_colors[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(colors), pointer(colors), GL_STATIC_DRAW)

    # Link vertex color data to the shader's color attribute
    color_attribute = glGetAttribLocation(shader_program, "color")
    glVertexAttribPointer(color_attribute, 4, GL_FLOAT, GL_FALSE, 0, C_NULL)
    glEnableVertexAttribArray(color_attribute)

    # Draw the vertices as a line loop
    glDrawArrays(GL_LINE_LOOP, 0, length(vertices))

    # Cleanup
    glDisableVertexAttribArray(pos_attribute)
    glDisableVertexAttribArray(color_attribute)
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindVertexArray(0)
    glDeleteBuffers(1, vbo_positions)
    glDeleteBuffers(1, vbo_colors)
    glDeleteVertexArrays(1, vao)
end

window_width_px = 800
window_height_px = 600

window = GLFW.Window(name="Drawing lines", resolution=(window_width_px, window_height_px))

vao = Ref(GLuint(0))
glGenVertexArrays(1, vao)
glBindVertexArray(vao[])

# The vertices of our rectangle
vertices = Point2f[(-0.5, 0.5), (0.5, 0.5), (0.5, -0.5), (-0.5, -0.5)]

# Per-vertex colors (RGBA)
colors = Vec{4,Float32}[
    Vec(1.0, 0.0, 0.0, 1.0),  # Red
    Vec(0.0, 1.0, 0.0, 1.0),  # Green
    Vec(0.0, 0.0, 1.0, 1.0),  # Blue
    Vec(1.0, 1.0, 0.0, 1.0)   # Yellow
]

# The shaders. Here we do everything manually, but life will get
# easier with GLAbstraction.

# The vertex shader
vertex_shader_source = """
#version 330 core
layout(location = 0) in vec2 position;
layout(location = 1) in vec4 color;

out vec4 v_color;

void main() {
    gl_Position = vec4(position, 0.0, 1.0);
    v_color = color;
}
"""
vertex_shader = glCreateShader(GL_VERTEX_SHADER)
glShaderSource(vertex_shader, vertex_shader_source)
glCompileShader(vertex_shader)

# The fragment shader
fragment_shader_source = """
#version 330 core
in vec4 v_color;
out vec4 FragColor;

void main() {
    FragColor = v_color;
}
"""

fragment_shader = glCreateShader(GL_FRAGMENT_SHADER)
glShaderSource(fragment_shader, fragment_shader_source)
glCompileShader(fragment_shader)

# Link the shaders into a program
shader_program = glCreateProgram()
glAttachShader(shader_program, vertex_shader)
glAttachShader(shader_program, fragment_shader)
glLinkProgram(shader_program)
glUseProgram(shader_program)

# Draw while waiting for a close event
glClearColor(0, 0, 0, 0)
while !GLFW.WindowShouldClose(window)
    glClear(GL_COLOR_BUFFER_BIT)

    # Draw the rectangle border using the reusable function
    draw_closed_lines(vertices, colors, shader_program)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
    if GLFW.GetKey(window, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window, true)
    end
end

GLFW.DestroyWindow(window)