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

    # Draw the border if border_width > 0
    if border_width_px > 0.0
        # Generate vertices for the border rectangle
        border_positions, border_colors, border_elements = generate_rectangle(
            container.x - border_width_x, container.y - border_width_y,
            container.width + 2 * border_width_x, container.height + 2 * border_width_y,
            border_color
        )

        # Generate buffers and vertex array for the border
        border_buffers = GLA.generate_buffers(prog[], position=border_positions, color=border_colors)
        border_vao = GLA.VertexArray(border_buffers, border_elements)

        # Bind and draw the border
        GLA.bind(prog[])
        GLA.bind(border_vao)
        GLA.draw(border_vao)
        GLA.unbind(border_vao)
        GLA.unbind(prog[])
    end

    # Generate vertices for the main rectangle
    vertex_positions, vertex_colors, elements = generate_rectangle(
        container.x, container.y, container.width, container.height, bg_color
    )

    # Generate buffers and vertex array for the main rectangle
    buffers = GLA.generate_buffers(prog[], position=vertex_positions, color=vertex_colors)
    vao = GLA.VertexArray(buffers, elements)

    # Bind and draw the main rectangle
    GLA.bind(prog[])
    GLA.bind(vao)
    GLA.draw(vao)
    GLA.unbind(vao)
    GLA.unbind(prog[])

    # Render child components
    for child in container.children
        render(child)
    end
end