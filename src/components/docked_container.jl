"""
A DockedContainer is a GUI component that can be docked to one of the four sides of a parent container.
"""
mutable struct DockedContainer <: AbstractDockedComponent
    x::Float32          # X position in NDC. Calculated value, not user input
    y::Float32          # Y position in NDC. Calculated value, not user input
    width::Float32      # Width in NDC. Calculated value, not user input
    height::Float32     # Width in NDC. Calculated value, not user input
    children::Vector{AbstractGuiComponent}  # Child components
    state::ComponentState
    style::ContainerStyle
    layout::DockedLayout
end

function DockedContainer()
    return DockedContainer(0.0, 0.0, 0.0, 0.0, AbstractGuiComponent[], ComponentState(), ContainerStyle(), DockedLayout())
end

function render(container::DockedContainer)
    # Apply layout to position child components
    apply_layout(container)

    # Fetch the window dimensions from the global window_info
    window_width_px = window_info.width_px
    window_height_px = window_info.height_px

    # Extract style properties
    bg_color = container.style.background_color
    border_color = container.style.border_color
    border_width_px = container.style.border_width_px

    # Convert border width from pixels to NDC
    border_width_x = px_to_ndc(border_width_px, window_width_px)
    border_width_y = px_to_ndc(border_width_px, window_height_px)

    # Generate vertices for the main rectangle
    vertex_positions = generate_rectangle_vertices(
        container.x, container.y, container.width, container.height
    )

    # Draw the main rectangle (background)
    draw_rectangle(vertex_positions, bg_color)

    if 0.0 < border_width_px
        draw_closed_lines(vertex_positions, border_color)
    end


    # Render child components
    for child in container.children
        render(child)
    end
end