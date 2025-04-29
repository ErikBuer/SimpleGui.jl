mutable struct ContainerStyle
    background_color::Vec4{<:AbstractFloat} #RGBA color
    border_color::Vec4{<:AbstractFloat} #RGBA color
    border_width_px::Float32
    # TODO shadow
end

function ContainerStyle(;
    background_color=Vec{4,Float32}(0.8f0, 0.8f0, 0.8f0, 1.0f0),
    border_color=Vec{4,Float32}(0.0f0, 0.0f0, 0.0f0, 1.0f0),
    border_width_px=1.0f0)
    return ContainerStyle(background_color, border_color, border_width_px)
end

"""
The `Container` struct represents a GUI component that can contain other components.
It is the most basic building block of the GUI system.
"""
mutable struct Container <: AbstractAlignedComponent
    x::Float32          # X position in NDC. Calculated value, not user input
    y::Float32          # Y position in NDC. Calculated value, not user input
    width::Float32      # Width in NDC. Calculated value, not user input
    height::Float32     # Width in NDC. Calculated value, not user input
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
    return Container(0.2, 0.2, 0.2, 0.2, AbstractGuiComponent[], ComponentState(), ContainerStyle(), AlignedLayout())
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

function render(container::Container)
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

    # Convert padding from pixels to NDC
    padding_px = container.layout.padding_px
    padding_x = px_to_ndc(padding_px, window_width_px)
    padding_y = px_to_ndc(padding_px, window_height_px)

    # Adjust container dimensions for padding
    padded_x = container.x + padding_x
    padded_y = container.y + padding_y
    padded_width = container.width - 2 * padding_x
    padded_height = container.height - 2 * padding_y

    # Generate vertices for the main rectangle
    vertex_positions = generate_rectangle_vertices(
        padded_x, padded_y, padded_width, padded_height
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