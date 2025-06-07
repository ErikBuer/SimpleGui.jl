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