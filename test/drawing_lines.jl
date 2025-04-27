using ModernGL, GeometryTypes, GLAbstraction, GLFW

"""
    dc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat

Convert NDC scale to pixels.

```jldoctest
julia> ndc_to_px(0.5, 800)
200.0
```
"""
function ndc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (dim / 2) * dim_px
end

"""
    px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat

Convert pixel to NDC scale.

```jldoctest
julia> px_to_ndc(200.0, 800)
0.5
```
"""
function px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (px / dim_px) * 2
end


function draw_closed_lines(vertices::Vector{Point2f0}, color::Tuple{Float32,Float32,Float32}, shader_program::GLuint)
    # Bind the shader program
    glUseProgram(shader_program)

    # Generate a Vertex Array Object (VAO)
    vao = Ref(GLuint(0))
    glGenVertexArrays(1, vao)
    glBindVertexArray(vao[])

    # Generate a Vertex Buffer Object (VBO) and upload vertex data
    vbo = Ref(GLuint(0))
    glGenBuffers(1, vbo)
    glBindBuffer(GL_ARRAY_BUFFER, vbo[])
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW)

    # Link vertex data to the shader's position attribute
    pos_attribute = glGetAttribLocation(shader_program, "position")
    glVertexAttribPointer(pos_attribute, 2, GL_FLOAT, GL_FALSE, 0, C_NULL)
    glEnableVertexAttribArray(pos_attribute)

    # Set the uniform color
    color_uniform = glGetUniformLocation(shader_program, "triangleColor")
    glUniform3f(color_uniform, color[1], color[2], color[3])

    # Draw the vertices as a line loop
    glDrawArrays(GL_LINE_LOOP, 0, length(vertices))

    # Cleanup
    glDisableVertexAttribArray(pos_attribute)
    glBindBuffer(GL_ARRAY_BUFFER, 0)
    glBindVertexArray(0)
    glDeleteBuffers(1, vbo)
    glDeleteVertexArrays(1, vao)
end

window_width_px = 800
window_height_px = 600

window = GLFW.Window(name="Drawing lines", resolution=(window_width_px, window_height_px))

vao = Ref(GLuint(0))
glGenVertexArrays(1, vao)
glBindVertexArray(vao[])

# The vertices of our rectangle
vertices = Point2f0[(-0.5, 0.5), (0.5, 0.5), (0.5, -0.5), (-0.5, -0.5)]


vbo = Ref(GLuint(0))   # initial value is irrelevant, just allocate space
glGenBuffers(1, vbo)
glBindBuffer(GL_ARRAY_BUFFER, vbo[])
glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW)

# The shaders. Here we do everything manually, but life will get
# easier with GLAbstraction.

# The vertex shader
vertex_source = """
#version 150

in vec2 position;

void main()
{
    gl_Position = vec4(position, 0.0, 1.0);
}
"""

# The fragment shader
fragment_source = """
# version 150

uniform vec3 triangleColor;

out vec4 outColor;

void main()
{
    outColor = vec4(triangleColor, 1.0);
}
"""

# Compile the vertex shader
vertex_shader = glCreateShader(GL_VERTEX_SHADER)
glShaderSource(vertex_shader, vertex_source)  # nicer thanks to GLAbstraction
glCompileShader(vertex_shader)
# Check that it compiled correctly
status = Ref(GLint(0))
glGetShaderiv(vertex_shader, GL_COMPILE_STATUS, status)
if status[] != GL_TRUE
    buffer = Array(UInt8, 512)
    glGetShaderInfoLog(vertex_shader, 512, C_NULL, buffer)
    @error "$(unsafe_string(pointer(buffer), 512))"
end

# Compile the fragment shader
fragment_shader = glCreateShader(GL_FRAGMENT_SHADER)
glShaderSource(fragment_shader, fragment_source)
glCompileShader(fragment_shader)
# Check that it compiled correctly
status = Ref(GLint(0))
glGetShaderiv(fragment_shader, GL_COMPILE_STATUS, status)
if status[] != GL_TRUE
    buffer = Array(UInt8, 512)
    glGetShaderInfoLog(fragment_shader, 512, C_NULL, buffer)
    @error "$(unsafe_string(pointer(buffer), 512))"
end

# Connect the shaders by combining them into a program
shader_program = glCreateProgram()
glAttachShader(shader_program, vertex_shader)
glAttachShader(shader_program, fragment_shader)
glBindFragDataLocation(shader_program, 0, "outColor") # optional

glLinkProgram(shader_program)
glUseProgram(shader_program)

# Link vertex data to attributes
pos_attribute = glGetAttribLocation(shader_program, "position")
glVertexAttribPointer(pos_attribute, length(eltype(vertices)),
    GL_FLOAT, GL_FALSE, 0, C_NULL)
glEnableVertexAttribArray(pos_attribute)

# Prepare to set uniforms
uni_color = glGetUniformLocation(shader_program, "triangleColor")

# Draw while waiting for a close event
glClearColor(0, 0, 0, 0)
while !GLFW.WindowShouldClose(window)
    glClear(GL_COLOR_BUFFER_BIT)

    # Set the border color (e.g., white)
    border_color = (1.0f0, 1.0f0, 1.0f0)

    # Draw the rectangle border using the reusable function
    draw_closed_lines(vertices, border_color, shader_program)

    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
    if GLFW.GetKey(window, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window, true)
    end
end

GLFW.DestroyWindow(window)