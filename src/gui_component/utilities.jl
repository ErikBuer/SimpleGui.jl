# Utilities for GUI components

using OffsetArrays, IndirectArrays


"""
    generate_rectangle_vertices(x, y, width, height)

Function to generate a rectangle with specified position and size in pixel coordinates.

This function creates a rectangle defined by its top-left corner (x, y), width, and height.
"""
function generate_rectangle_vertices(x, y, width, height)::Vector{Point{2,Float32}}
    vertices = Point{2,Float32}[
        Point{2,Float32}(x, y),                    # Top-left
        Point{2,Float32}(x, y + height),           # Bottom-left
        Point{2,Float32}(x + width, y + height),   # Bottom-right
        Point{2,Float32}(x + width, y),            # Top-right   
    ]
    return vertices
end

"""
    draw_closed_lines(vertices::Vector{Point2f}, color_rgba::Vec4{<:AbstractFloat})

Draw closed lines using the provided vertices and color.
"""
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

"""
    draw_rectangle(vertices::Vector{Point2f}, color_rgba::Vec4{<:AbstractFloat}, projection_matrix::Mat4{Float32})

Draw a rectangle using the provided vertices and color.
"""
function draw_rectangle(vertices::Vector{Point2f}, color_rgba::Vec4{<:AbstractFloat}, projection_matrix::Mat4{Float32})
    # Generate a uniform color array for all vertices
    colors = Vec{4,Float32}[color_rgba for _ in 1:4]

    # Define the elements (two triangles forming the rectangle)
    elements = NgonFace{3,UInt32}[
        (0, 1, 2),  # First triangle: bottom-left, bottom-right, top-right
        (2, 3, 0)   # Second triangle: top-right, top-left, bottom-left
    ]

    # Generate buffers for positions and colors
    buffers = GLA.generate_buffers(prog[], position=vertices, color=colors)

    # Create a Vertex Array Object (VAO) with the primitive type GL_TRIANGLES
    vao = GLA.VertexArray(buffers, elements)

    # Bind the shader program and VAO
    GLA.bind(prog[])
    GLA.bind(vao)

    # Ensure the shader's `use_texture` uniform is set to `false`
    GLA.gluniform(prog[], :use_texture, false)
    GLA.gluniform(prog[], :projection, projection_matrix)

    # Draw the rectangle using the VAO
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(prog[])
end

function load_texture(file_path::String)::GLAbstraction.Texture
    # Load the image using FileIO
    img = FileIO.load(file_path)  # Returns a Matrix or IndirectArray

    # If the image is an IndirectArray, materialize it into a standard array
    if img isa IndirectArrays.IndirectArray
        @debug("Materializing IndirectArray into a standard array...")
        img = img.values[img.index]
    end

    # Create a GLAbstraction texture
    texture = GLA.Texture(img;
        minfilter=:linear,
        magfilter=:linear,
        x_repeat=:clamp_to_edge,
        y_repeat=:clamp_to_edge
    )

    return texture
end

function create_sdf_texture(sdf_matrix::Matrix{Float32})::GLAbstraction.Texture
    # Create a GLAbstraction.Texture
    texture = GLA.Texture(sdf_matrix;
        minfilter=:linear,
        magfilter=:linear,
        x_repeat=:clamp_to_edge,
        y_repeat=:clamp_to_edge
    )

    return texture
end

function draw_image(texture::GLAbstraction.Texture, x_px::AbstractFloat, y_px::AbstractFloat, projection_matrix::Mat4{Float32}; scale::AbstractFloat=1.0)

    # Get the image size from the texture
    width_px, height_px = Float32.(GLA.size(texture))


    scaled_width_px = width_px * scale
    scaled_height_px = height_px * scale

    # Define rectangle vertices
    positions = [
        Point2f(x_px, y_px + scaled_height_px),                   # Bottom-left
        Point2f(x_px + scaled_width_px, y_px + scaled_height_px), # Bottom-right
        Point2f(x_px + scaled_width_px, y_px),                    # Top-right
        Point2f(x_px, y_px),                                      # Top-left
    ]

    # Define texture coordinates
    texturecoordinates = [
        Vec{2,Float32}(1.0f0, 0.0f0),  # Bottom-right
        Vec{2,Float32}(1.0f0, 1.0f0),  # Top-right
        Vec{2,Float32}(0.0f0, 1.0f0),  # Top-left    
        Vec{2,Float32}(0.0f0, 0.0f0),  # Bottom-left
    ]

    # Define the elements (two triangles forming the rectangle)
    indices = NgonFace{3,UInt32}[
        (0, 1, 2),  # First triangle: bottom-left, bottom-right, top-right
        (2, 3, 0)   # Second triangle: top-right, top-left, bottom-left
    ]

    # Generate buffers and create a Vertex Array Object (VAO)
    vao = GLA.VertexArray(
        GLA.generate_buffers(
            prog[],
            position=positions,
            texcoord=texturecoordinates
        ),
        indices
    )

    # Bind the shader program
    GLA.bind(prog[])

    # Set the `use_texture` uniform to true
    GLA.gluniform(prog[], :use_texture, true)

    # Bind the texture to the shader's sampler2D uniform
    GLA.gluniform(prog[], :image, 0, texture)

    GLA.gluniform(prog[], :projection, projection_matrix)

    # Bind the VAO and draw the rectangle
    GLA.bind(vao)
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(prog[])
end

function create_text_texture(sdf_matrix::Matrix{Float32})::GLAbstraction.Texture
    # Create a GLAbstraction.Texture
    texture = GLA.Texture(sdf_matrix;
        minfilter=:linear,
        magfilter=:linear,
        x_repeat=:clamp_to_edge,
        y_repeat=:clamp_to_edge
    )

    return texture
end

function draw_text(
    font_face::FreeTypeAbstraction.FTFont,
    text::String,
    x_px::Float32,
    y_px::Float32,
    pixelsize::Int,
    projection_matrix::Mat4{Float32}
)
    current_x = x_px

    for char in text
        # Render the glyph and get its bitmap and extent
        bitmap, extent = FreeTypeAbstraction.renderface(font_face, char, pixelsize)

        # Skip empty glyphs
        if isempty(bitmap) || size(bitmap, 1) == 0 || size(bitmap, 2) == 0
            continue
        end

        # Convert the bitmap to a Matrix{Float32}
        bitmap_matrix = Float32.(bitmap) ./ 255.0f0  # Normalize to [0.0, 1.0]

        # Create a texture from the bitmap
        texture = SimpleGui.create_text_texture(bitmap_matrix)

        # Calculate the width and height of the glyph
        width_px = Float32(size(bitmap_matrix, 2))  # Glyph width
        height_px = Float32(size(bitmap_matrix, 1)) # Glyph height

        # Draw the glyph at the current position
        SimpleGui.draw_glyph(
            texture,
            current_x + Float32(extent.horizontal_bearing[1]),  # Adjust for horizontal bearing
            y_px - Float32(extent.horizontal_bearing[2]),       # Adjust for vertical bearing
            projection_matrix;
            scale=1.0
        )

        # Advance the x position by the glyph's advance width
        current_x += Float32(extent.advance[1])
    end
end

function draw_glyph(texture::GLAbstraction.Texture, x_px::AbstractFloat, y_px::AbstractFloat, projection_matrix::Mat4{Float32}; scale::AbstractFloat=1.0)
    # Get the image size from the texture
    width_px, height_px = Float32.(GLA.size(texture))

    scaled_width_px = width_px * scale
    scaled_height_px = height_px * scale

    # Define rectangle vertices
    positions = [
        Point2f(x_px, y_px + scaled_height_px),                   # Top-left
        Point2f(x_px + scaled_width_px, y_px + scaled_height_px), # Top-right
        Point2f(x_px + scaled_width_px, y_px),                    # Bottom-right
        Point2f(x_px, y_px),                                      # Bottom-left
    ]

    # Define texture coordinates (corrected for OpenGL's coordinate system)
    texturecoordinates = [
        Vec{2,Float32}(0.0f0, 1.0f0),  # Top-left
        Vec{2,Float32}(1.0f0, 1.0f0),  # Top-right
        Vec{2,Float32}(1.0f0, 0.0f0),  # Bottom-right
        Vec{2,Float32}(0.0f0, 0.0f0),  # Bottom-left
    ]

    # Define the elements (two triangles forming the rectangle)
    indices = NgonFace{3,UInt32}[
        (0, 1, 2),  # First triangle
        (2, 3, 0)   # Second triangle
    ]

    # Generate buffers and create a Vertex Array Object (VAO)
    vao = GLA.VertexArray(
        GLA.generate_buffers(
            prog[],
            position=positions,
            texcoord=texturecoordinates
        ),
        indices
    )

    # Bind the shader program
    GLA.bind(prog[])

    # Set the `use_texture` uniform to true
    GLA.gluniform(prog[], :use_texture, true)

    # Bind the texture to the shader's sampler2D uniform
    GLA.gluniform(prog[], :image, 0, texture)

    GLA.gluniform(prog[], :projection, projection_matrix)

    # Bind the VAO and draw the rectangle
    GLA.bind(vao)
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(prog[])
end

function draw_text_sdf(
    sdf_texture::GLAbstraction.Texture,
    x_px::Float32,
    y_px::Float32,
    width_px::Float32,
    height_px::Float32,
    projection_matrix::Mat4{Float32},
    text_color::Vec4{Float32}=Vec{4,Float32}(1.0, 1.0, 1.0, 1.0),
    smoothing::Float32=0.05f0
)
    # Define rectangle vertices
    positions = [
        Point2f(x_px, y_px + height_px),            # Bottom-left
        Point2f(x_px + width_px, y_px + height_px), # Bottom-right
        Point2f(x_px + width_px, y_px),             # Top-right
        Point2f(x_px, y_px),                        # Top-left
    ]

    # Define texture coordinates
    texcoords = [
        Vec{2,Float32}(0.0, 1.0),  # Bottom-left
        Vec{2,Float32}(1.0, 1.0),  # Bottom-right
        Vec{2,Float32}(1.0, 0.0),  # Top-right
        Vec{2,Float32}(0.0, 0.0),  # Top-left
    ]

    # Define the elements (two triangles forming the rectangle)
    indices = NgonFace{3,UInt32}[
        (0, 1, 2),  # First triangle
        (2, 3, 0)   # Second triangle
    ]

    # Generate buffers and create a Vertex Array Object (VAO)
    vao = GLA.VertexArray(
        GLA.generate_buffers(
            sdf_prog[],
            position=positions,
            texcoord=texcoords
        ),
        indices
    )

    # Bind the SDF shader program
    GLA.bind(sdf_prog[])

    # Set uniforms
    GLA.gluniform(sdf_prog[], :projection, projection_matrix)
    GLA.gluniform(sdf_prog[], :text_color, text_color)
    GLA.gluniform(sdf_prog[], :smoothing, smoothing)

    # Bind the SDF texture
    GLA.gluniform(sdf_prog[], :sdfTexture, 0, sdf_texture)

    # Bind the VAO and draw the rectangle
    GLA.bind(vao)
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(sdf_prog[])
end

function inside_rect(x::AbstractFloat, y::AbstractFloat, width::AbstractFloat, height::AbstractFloat, mouse_x::AbstractFloat, mouse_y::AbstractFloat)::Bool
    return mouse_x >= x && mouse_x <= x + width && mouse_y >= y && mouse_y <= y + height
end

"""
    inside_rectangular_component(component::AbstractGuiComponent, mouse_state::MouseState)::Bool

Check if the mouse is inside a rectangular component.
"""
function inside_rectangular_component(component::AbstractGuiComponent, mouse_state::MouseState)::Bool
    # Check if the mouse is inside the component's rectangular area
    x, y = mouse_state.x, mouse_state.y

    return (x >= component.x && x <= component.x + component.width &&
            y >= component.y && y <= component.y + component.height)
end

"""
    dc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat

Convert NDC scale to pixels.

```jldoctest
julia> using SimpleGui

julia> SimpleGui.ndc_to_px(0.5, 800)
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
julia> using SimpleGui

julia> SimpleGui.px_to_ndc(200.0, 800)
0.5
```
"""
function px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (px / dim_px) * 2
end