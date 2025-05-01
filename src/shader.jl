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


# Global variable for the shader program
const prog = Ref{GLA.Program}()

# Initialize the shader program (must be called after OpenGL context is created)
function initialize_shaders()
    prog[] = GLA.Program(vertex_shader, fragment_shader)
end