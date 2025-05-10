mutable struct ContainerStyle
    background_color::Vec4{<:AbstractFloat} #RGBA color
    border_color::Vec4{<:AbstractFloat} #RGBA color
    border_width_px::Float32
end

function ContainerStyle(;
    background_color=Vec4{Float32}(0.8f0, 0.8f0, 0.8f0, 1.0f0),
    border_color=Vec4{Float32}(0.0f0, 0.0f0, 0.0f0, 1.0f0),
    border_width_px=1.0f0)
    return ContainerStyle(background_color, border_color, border_width_px)
end

"""
The `Container` struct represents a GUI component that can contain other components.
It is the most basic building block of the GUI system.
"""
mutable struct Container <: AbstractAlignedComponent
    x::Float32          # X position in pixels. Calculated value, not user input
    y::Float32          # Y position in pixels. Calculated value, not user input
    width::Float32      # Width in pixels. Calculated value, not user input
    height::Float32     # Width in pixels. Calculated value, not user input
    children::Vector{AbstractGuiComponent}  # Child components
    state::ComponentState
    style::ContainerStyle
    layout::AlignedLayout
end

# Constructor for internal use
function _Container(x, y, width, height, children=Vector{AbstractGuiComponent}())
    return Container(x, y, width, height, children, ComponentState(), ContainerStyle(), AlignedLayout())
end

"""
Container constructor.
"""
function Container()
    return Container(0.0, 0.0, 100.0, 100.0, AbstractGuiComponent[], ComponentState(), ContainerStyle(), AlignedLayout())
end

function handle_click(container::Container, mouse_state::MouseState)
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

function handle_mouse_enter(container::Container, mouse_state::MouseState)
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

function handle_mouse_leave(container::Container, mouse_state::MouseState)
    state = get_state(container)
    if !(inside_rectangular_component(container, mouse_state))
        if state.is_hovered
            state.is_hovered = false
            dispatch_event(container, OnMouseLeave, mouse_state)
        end
    end
end

function handle_mouse_over(container::Container, mouse_state::MouseState)
    state = get_state(container)

    # Check if the mouse is inside the container's bounds
    if inside_rectangular_component(container, mouse_state)
        # Dispatch the OnMouseOver event
        dispatch_event(container, OnMouseOver, mouse_state)
    end
end

function render(container::Container, projection_matrix::Mat4{Float32})
    # Apply layout to position child components
    apply_layout(container)

    # Extract style properties
    bg_color = container.style.background_color
    border_color = container.style.border_color
    border_width_px = container.style.border_width_px
    padding_px = container.layout.padding_px

    # Adjust container dimensions for padding
    padded_x = container.x + padding_px
    padded_y = container.y + padding_px
    padded_width = container.width - 2 * padding_px
    padded_height = container.height - 2 * padding_px

    # Generate vertices for the main rectangle
    vertex_positions = generate_rectangle_vertices(
        padded_x, padded_y, padded_width, padded_height
    )

    # Draw the main rectangle (background)
    draw_rectangle(vertex_positions, bg_color, projection_matrix::Mat4{Float32})

    if 0.0 < border_width_px
        draw_closed_lines(vertex_positions, border_color)
    end

    # Render child components
    for child in container.children
        render(child, projection_matrix)
    end
end