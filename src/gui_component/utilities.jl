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