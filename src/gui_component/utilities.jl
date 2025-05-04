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
    draw_rectangle(vertices::Vector{Point2f}, color_rgba::Vec4{<:AbstractFloat})

Draw a rectangle using the provided vertices and color.
"""
function draw_rectangle(vertices::Vector{Point2f}, color_rgba::Vec4{<:AbstractFloat})
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

    global projection_matrix
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

    # Transpose the image to match OpenGL's coordinate system
    img = permutedims(img)  # Swap dimensions 1 and 2 for proper orientation

    # Create a GLAbstraction texture
    texture = GLA.Texture(img; minfilter=:linear, magfilter=:linear, x_repeat=:clamp_to_edge, y_repeat=:clamp_to_edge)

    return texture
end

function draw_image(texture::GLAbstraction.Texture, x::AbstractFloat, y::AbstractFloat; scale::AbstractFloat=1.0)
    global window_info

    # Get the image size from the texture
    width_px, height_px = GLA.size(texture)

    # Convert image size to normalized device coordinates (NDC)
    width_ndc = px_to_ndc(width_px * scale, window_info.width_px)
    height_ndc = px_to_ndc(height_px * scale, window_info.height_px)

    # Define rectangle vertices
    positions = [
        Point2f(x, y),                          # Bottom-left
        Point2f(x + width_ndc, y),              # Bottom-right
        Point2f(x, y + height_ndc),             # Top-left
        Point2f(x + width_ndc, y + height_ndc)  # Top-right
    ]

    # Define texture coordinates
    texturecoordinates = [
        Vec{2,Float32}(0.0f0, 1.0f0),  # Bottom-left
        Vec{2,Float32}(1.0f0, 1.0f0),  # Bottom-right
        Vec{2,Float32}(0.0f0, 0.0f0),  # Top-left
        Vec{2,Float32}(1.0f0, 0.0f0)   # Top-right
    ]

    # Define indices for two triangles forming the rectangle
    indices = TriangleFace{OffsetInteger{-1,UInt32}}[
        TriangleFace{OffsetInteger{-1,UInt32}}((OffsetInteger{-1,UInt32}(1), OffsetInteger{-1,UInt32}(2), OffsetInteger{-1,UInt32}(4))),  # First triangle
        TriangleFace{OffsetInteger{-1,UInt32}}((OffsetInteger{-1,UInt32}(4), OffsetInteger{-1,UInt32}(3), OffsetInteger{-1,UInt32}(1)))   # Second triangle
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

    # Bind the VAO and draw the rectangle
    GLA.bind(vao)
    GLA.draw(vao)

    # Unbind the VAO and shader program
    GLA.unbind(vao)
    GLA.unbind(prog[])
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