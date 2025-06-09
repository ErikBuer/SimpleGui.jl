function draw_text(
    font_face::FreeTypeAbstraction.FTFont,
    text::AbstractString,
    x_px::Float32,
    y_px::Float32,
    pixelsize::Int,
    projection_matrix::Mat4{Float32},
    color::Vec4{Float32}
)
    current_x = x_px

    # Initialize prev_char to nothing
    local prev_char::Union{Char,Nothing} = nothing

    for char in text
        # Render the glyph and get its bitmap and extent
        bitmap, extent = FreeTypeAbstraction.renderface(font_face, char, pixelsize)

        # Handle kerning between characters
        if prev_char !== nothing
            kx, _ = map(x -> round(Int, x), FreeTypeAbstraction.kerning(prev_char, char, font_face))
            current_x += kx
        end

        # Skip empty glyphs (e.g., spaces may have no bitmap but still have advance width)
        if isempty(bitmap) || size(bitmap, 1) == 0 || size(bitmap, 2) == 0
            current_x += Float32(extent.advance[1])  # Advance the pen position for spaces
            prev_char = char
            continue
        end

        # Convert the bitmap to a Matrix{Float32}
        bitmap_matrix = Float32.(bitmap) ./ 255.0f0  # Normalize to [0.0, 1.0]

        # Create a texture from the bitmap
        texture = create_text_texture(bitmap_matrix)

        # Calculate the glyph's position
        glyph_x = current_x + Float32(extent.horizontal_bearing[1])
        glyph_y = y_px - Float32(extent.horizontal_bearing[2])

        # Render the glyph
        draw_glyph(texture, glyph_x, glyph_y, projection_matrix; scale=1.0, color=color)

        # Advance the pen position
        current_x += Float32(extent.advance[1])
        prev_char = char
    end
end

function draw_glyph(texture::GLAbstraction.Texture, x_px::AbstractFloat, y_px::AbstractFloat, projection_matrix::Mat4{Float32}; scale::AbstractFloat=1.0, color::Vec4{Float32}=Vec{4,Float32}(1.0, 1.0, 1.0, 1.0))
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
            glyph_prog[],
            position=positions,
            texcoord=texturecoordinates
        ),
        indices
    )

    # Bind the shader program
    GLA.bind(glyph_prog[])

    # Set the `use_texture` uniform to true
    GLA.gluniform(glyph_prog[], :use_texture, true)
    GLA.gluniform(glyph_prog[], :image, 0, texture)
    GLA.gluniform(glyph_prog[], :projection, projection_matrix)
    GLA.gluniform(glyph_prog[], :text_color, color)

    # Bind the VAO and draw the rectangle
    GLA.bind(vao)
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(glyph_prog[])
end