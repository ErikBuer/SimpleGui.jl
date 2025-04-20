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