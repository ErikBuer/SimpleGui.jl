const vertex_shader = GLA.vert"""
#version 330 core
layout(location = 0) in vec2 position; // Position in pixels
layout(location = 1) in vec4 color;
layout(location = 2) in vec2 texcoord;

out vec4 v_color;
out vec2 v_texcoord;

uniform mat4 projection; // Projection matrix

void main() {
    // Transform position from pixels to NDC using the projection matrix
    gl_Position = projection * vec4(position, 0.0, 1.0);

    v_color = color;
    v_texcoord = texcoord;
}
"""

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

const glyph_vertex_shader = GLA.vert"""
#version 330 core
layout(location = 0) in vec2 position; // Glyph position in pixels
layout(location = 1) in vec2 texcoord; // Texture coordinates

out vec2 v_texcoord;

uniform mat4 projection; // Projection matrix

void main() {
    // Transform position from pixels to NDC using the projection matrix
    gl_Position = projection * vec4(position, 0.0, 1.0);
    v_texcoord = texcoord; // Pass texture coordinates to the fragment shader
}
"""

const glyph_fragment_shader = GLA.frag"""
#version 330 core
in vec2 v_texcoord;
out vec4 FragColor;

uniform sampler2D image;       // Glyph texture
uniform vec4 text_color;       // Text color

void main() {
    // Sample the glyph texture
    vec4 sampled = texture(image, v_texcoord);

    // Apply the text color and alpha from the texture
    FragColor = vec4(text_color.rgb, sampled.r * text_color.a);
}
"""


# Global variable for the shader program
const prog = Ref{GLA.Program}()
const glyph_prog = Ref{GLA.Program}()



"""
Initialize the shader program (must be called after OpenGL context is created)
"""
function initialize_shaders()
    prog[] = GLA.Program(vertex_shader, fragment_shader)
    glyph_prog[] = GLA.Program(glyph_vertex_shader, glyph_fragment_shader)
end