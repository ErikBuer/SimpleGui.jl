# Utilities for GUI components


"""
    generate_rectangle(x, y, width, height, color)

Function to generate a rectangle with specified position, size, and color

This function creates a rectangle defined by its bottom-left corner (x, y), width, height, and color.
It returns the vertices, colors, and elements needed to render the rectangle.
"""
function generate_rectangle(x, y, width, height, color)
    # Define the vertices for the rectangle in counterclockwise order
    vertices = Point{2,Float32}[
        Point{2,Float32}(x, y),                    # Bottom-left
        Point{2,Float32}(x + width, y),            # Bottom-right
        Point{2,Float32}(x + width, y + height),   # Top-right
        Point{2,Float32}(x, y + height)            # Top-left
    ]

    # Define the colors for each vertex
    colors = [Vec(color...) for _ in 1:4]

    # Define the elements (two triangles forming the rectangle)
    elements = NgonFace{3,UInt32}[
        (0, 1, 2),  # First triangle: bottom-left, bottom-right, top-right
        (2, 3, 0)   # Second triangle: top-right, top-left, bottom-left
    ]

    return vertices, colors, elements
end

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
julia> ndc_to_px(0.5, 800)
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
julia> px_to_ndc(200.0, 800)
0.5
```
"""
function px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (px / dim_px) * 2
end