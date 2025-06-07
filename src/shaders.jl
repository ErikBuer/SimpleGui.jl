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
    v_texcoord = texcoord;
}
"""

const glyph_fragment_shader = GLA.frag"""
#version 330 core
in vec2 v_texcoord;
out vec4 FragColor;

uniform sampler2D sdfTexture;
uniform vec4 text_color;  // Text color
uniform float smoothing;  // Smoothing factor

void main() {
    // Sample the SDF texture
    float sdfValue = texture(sdfTexture, v_texcoord).r;

    // Apply smoothing to calculate alpha
    float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, sdfValue) * text_color.a;

    // Set the fragment color using the text color and alpha
    FragColor = vec4(text_color.rgb, alpha);
}
"""


# Global variable for the shader program
const prog = Ref{GLA.Program}()
const sdf_prog = Ref{GLA.Program}()



"""
Initialize the shader program (must be called after OpenGL context is created)
"""
function initialize_shaders()
    prog[] = GLA.Program(vertex_shader, fragment_shader)
    sdf_prog[] = GLA.Program(glyph_vertex_shader, glyph_fragment_shader)
end