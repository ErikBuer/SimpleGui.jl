using ModernGL, GLFW, GLAbstraction
const GLA = GLAbstraction

using GeometryBasics
using FreeTypeAbstraction
using ColorTypes
using OffsetArrays

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
const window = GLFW.Window(name="Text Rendering Example", resolution=(window_info.width_px, window_info.height_px))
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
const sdf_fragment_shader = GLA.frag"""
#version 330 core
in vec2 v_texcoord;

out vec4 FragColor;

uniform sampler2D sdf_image; // SDF texture
uniform vec4 text_color;     // Configurable text color
uniform float smoothing;     // Controls edge smoothing

void main() {
    float distance = texture(sdf_image, v_texcoord).r; // Sample the SDF texture
    float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance); // Smooth edges
    FragColor = vec4(text_color.rgb, text_color.a * alpha); // Apply color and alpha
}
"""

# Compile the shader program
sdf_program = GLA.Program(vertex_shader, sdf_fragment_shader)


using FreeTypeAbstraction, GeometryBasics

struct GlyphAtlas
    texture::GLA.Texture
    uv_coords::Dict{Char,Vec4f}  # UV coordinates for each glyph
end

function create_glyph_atlas(font_face, font_size::Integer)
    atlas_size = (1024, 1024)  # Size of the texture atlas
    atlas = zeros(Float32, atlas_size...)  # Initialize the atlas texture
    uv_coords = Dict{Char,Vec4f}()  # Store UV coordinates for each glyph

    x_offset, y_offset = 0, 0
    max_row_height = 0

    for char in Char(' '):Char('~')  # ASCII range
        # Render the glyph using renderface
        glyph, _ = renderface(font_face, char, font_size)  # Extract the glyph bitmap
        glyph_height, glyph_width = size(glyph)  # Note: size returns (rows, cols)

        # Check if the glyph fits in the current row
        if x_offset + glyph_width > atlas_size[2]
            # Move to the next row
            x_offset = 0
            y_offset += max_row_height
            max_row_height = 0
        end

        # Check if the glyph fits in the atlas
        if y_offset + glyph_height > atlas_size[1]
            error("Atlas size is too small for all glyphs!")
        end

        # Copy the glyph into the atlas
        atlas[y_offset+1:y_offset+glyph_height, x_offset+1:x_offset+glyph_width] .= glyph

        # Store the UV coordinates
        uv_coords[char] = Vec4f(
            x_offset / atlas_size[2],
            y_offset / atlas_size[1],
            glyph_width / atlas_size[2],
            glyph_height / atlas_size[1]
        )

        # Update offsets
        x_offset += glyph_width
        max_row_height = max(max_row_height, glyph_height)
    end

    # Create a GL texture from the atlas
    texture = GLA.Texture(atlas; minfilter=:linear, magfilter=:linear)

    return GlyphAtlas(texture, uv_coords)
end

struct GlyphMetrics
    advance::Float32
    bounds::Vec4f  # (xmin, ymin, xmax, ymax)
end

function compute_glyph_metrics(font_face, char, font_size::Integer)
    extent = FreeTypeAbstraction.GlyphExtent(font_face, char)
    scale = font_size / font_face.units_per_EM
    advance = extent.hadvance * scale
    bounds = Vec4f(
        extent.left * scale,
        extent.bottom * scale,
        extent.right * scale,
        extent.top * scale
    )
    return GlyphMetrics(advance, bounds)
end

function generate_text_quads(text::String, atlas::GlyphAtlas, font_face, font_size::Integer, x::Float32, y::Float32)
    vertices = Point2f[]
    texcoords = Vec2f[]
    indices = UInt32[]

    cursor_x = x
    cursor_y = y
    index_offset = 0

    for char in text
        metrics = compute_glyph_metrics(font_face, char, font_size)
        uv = atlas.uv_coords[char]

        # Calculate quad vertices
        xmin = cursor_x + metrics.bounds[1]
        ymin = cursor_y + metrics.bounds[2]
        xmax = cursor_x + metrics.bounds[3]
        ymax = cursor_y + metrics.bounds[4]

        push!(vertices, Point2f(xmin, ymin), Point2f(xmax, ymin), Point2f(xmin, ymax), Point2f(xmax, ymax))
        push!(texcoords, Vec2f(uv[1], uv[2] + uv[4]), Vec2f(uv[1] + uv[3], uv[2] + uv[4]),
            Vec2f(uv[1], uv[2]), Vec2f(uv[1] + uv[3], uv[2]))

        # Add indices for two triangles
        push!(indices, index_offset + 1, index_offset + 2, index_offset + 3)
        push!(indices, index_offset + 3, index_offset + 2, index_offset + 4)
        index_offset += 4

        # Advance cursor
        cursor_x += metrics.advance
    end

    return vertices, texcoords, indices
end


function create_glyph_atlas(font_face, font_size::Integer)
    atlas_size = (1024, 1024)  # Size of the texture atlas
    atlas = zeros(Float32, atlas_size...)  # Initialize the atlas texture
    uv_coords = Dict{Char,Vec4f}()  # Store UV coordinates for each glyph

    x_offset, y_offset = 0, 0
    max_row_height = 0

    for char in Char(' '):Char('~')  # ASCII range
        # Render the glyph using renderface
        glyph, _ = renderface(font_face, char, font_size)  # Extract the glyph bitmap
        glyph_width, glyph_height = size(glyph)

        # Move to the next row if the glyph doesn't fit in the current row
        if x_offset + glyph_width > atlas_size[1]
            x_offset = 0
            y_offset += max_row_height
            max_row_height = 0
        end

        # Check if the glyph fits in the atlas
        if y_offset + glyph_height > atlas_size[2]
            error("Atlas size is too small for all glyphs!")
        end

        # Copy the glyph into the atlas
        atlas[y_offset+1:y_offset+glyph_height, x_offset+1:x_offset+glyph_width] .= glyph

        # Store the UV coordinates
        uv_coords[char] = Vec4f(
            x_offset / atlas_size[1],
            y_offset / atlas_size[2],
            glyph_width / atlas_size[1],
            glyph_height / atlas_size[2]
        )

        # Update offsets
        x_offset += glyph_width
        max_row_height = max(max_row_height, glyph_height)
    end

    # Create a GL texture from the atlas
    texture = GLA.Texture(atlas; minfilter=:linear, magfilter=:linear)

    return GlyphAtlas(texture, uv_coords)
end


# Load a font using FreeTypeAbstraction
font_face = findfont("arial")
if font_face === nothing
    error("Font not found!")
end

font_size = 30

atlas = create_glyph_atlas(font_face, font_size)

glClearColor(0.0, 0.0, 0.0, 1.0)
while !GLFW.WindowShouldClose(window)
    glClear(GL_COLOR_BUFFER_BIT)

    # Render text using the glyph atlas
    render_text_with_atlas(
        "SDF Text Example",
        atlas,
        font_face,
        font_size,
        -0.8f0, 0.0f0,
        Vec4(1.0f0, 0.5f0, 0.0f0, 1.0f0),  # Orange text color
        0.02f0                             # Smoothing factor
    )

    # Swap buffers and poll events
    GLFW.SwapBuffers(window)
    GLFW.PollEvents()
    if GLFW.GetKey(window, GLFW.KEY_ESCAPE) == GLFW.PRESS
        GLFW.SetWindowShouldClose(window, true)
    end
end

GLFW.DestroyWindow(window)