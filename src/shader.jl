# Vertex and Fragment Shaders
const vertex_shader = GLA.vert"""
#version 150

in vec2 position;
in vec4 color;

out vec4 Color;

void main()
{
    Color = color;
    gl_Position = vec4(position, 0.0, 1.0);
}
"""

const fragment_shader = GLA.frag"""
#version 150

in vec4 Color;

out vec4 outColor;

void main()
{
    outColor = Color;
}
"""


# Global variable for the shader program
const prog = Ref{GLA.Program}()

# Initialize the shader program (must be called after OpenGL context is created)
function initialize_shaders()
    prog[] = GLA.Program(vertex_shader, fragment_shader)
end