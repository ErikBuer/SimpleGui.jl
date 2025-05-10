"""
A DockedContainer is a GUI component that can be docked to one of the four sides of a parent container.
"""
mutable struct DockedContainer <: AbstractDockedComponent
    x::Float32          # X position in pixels. Calculated value, not user input
    y::Float32          # Y position in pixels. Calculated value, not user input
    width::Float32      # Width in pixels. Calculated value, not user input
    height::Float32     # Width in pixels. Calculated value, not user input
    children::Vector{AbstractGuiComponent}  # Child components
    state::ComponentState
    style::ContainerStyle
    layout::DockedLayout
end

function DockedContainer()
    return DockedContainer(0.0, 0.0, 100.0, 100.0, AbstractGuiComponent[], ComponentState(), ContainerStyle(), DockedLayout())
end

function render(container::DockedContainer, projection_matrix::Mat4{Float32})
    # Apply layout to position child components
    apply_layout(container)

    # Extract style properties
    bg_color = container.style.background_color
    border_color = container.style.border_color
    border_width_px = container.style.border_width_px

    # Generate vertices for the main rectangle
    vertex_positions = generate_rectangle_vertices(
        container.x, container.y, container.width, container.height
    )

    # Draw the main rectangle (background)
    draw_rectangle(vertex_positions, bg_color, projection_matrix::Mat4{Float32})

    if 0.0 < border_width_px
        draw_closed_lines(vertex_positions, border_color)
    end

    # Render child components
    for child in container.children
        render(child)
    end
end

function handle_click(container::DockedContainer, mouse_state::MouseState)
    state = get_state(container)

    if inside_rectangular_component(container, mouse_state)
        if mouse_state.button_state[GLFW.MOUSE_BUTTON_LEFT] == IsPressed
            if !state.is_clicked
                state.is_clicked = true
                dispatch_event(container, OnClick)
            end
        elseif state.is_clicked
            state.is_clicked = false
        end
    end
end

function handle_mouse_enter(container::DockedContainer, mouse_state::MouseState)
    state = get_state(container)
    if inside_rectangular_component(container, mouse_state)
        if !state.is_hovered
            state.is_hovered = true
            dispatch_event(container, OnMouseEnter, mouse_state)
        end
    else
        if state.is_hovered
            state.is_hovered = false
        end
    end
end

function handle_mouse_leave(container::DockedContainer, mouse_state::MouseState)
    state = get_state(container)
    if !(inside_rectangular_component(container, mouse_state))
        if state.is_hovered
            state.is_hovered = false
            dispatch_event(container, OnMouseLeave, mouse_state)
        end
    end
end

function handle_mouse_over(container::DockedContainer, mouse_state::MouseState)
    state = get_state(container)

    # Check if the mouse is inside the container's bounds
    if inside_rectangular_component(container, mouse_state)
        # Dispatch the OnMouseOver event
        dispatch_event(container, OnMouseOver, mouse_state)
    end
end