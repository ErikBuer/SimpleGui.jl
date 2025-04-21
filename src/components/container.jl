mutable struct ContainerStyle
    background_color::Tuple{Float32,Float32,Float32,Float32}
    border_color::Tuple{Float32,Float32,Float32,Float32}
    border_width_px::Float32
end

# Default style for Container
function ContainerStyle(; background_color=(0.8, 0.8, 0.8, 1.0), border_color=(0.5, 0.5, 0.5, 1.0), border_width_px=1)
    return ContainerStyle(background_color, border_color, border_width_px)
end

"""
The `Container` struct represents a GUI component that can contain other components.
It is the most basic building block of the GUI system.
"""
mutable struct Container <: GuiComponent
    x::Float32          # X position in NDC. Calculated value, not user input
    y::Float32          # Y position in NDC. Calculated value, not user input
    width::Float32      # Width in NDC. Calculated value, not user input
    height::Float32     # Width in NDC. Calculated value, not user input
    children::Vector{GuiComponent}  # Child components
    state::ComponentState
    style::ContainerStyle
    layout::Layout
end

# Constructor for internal use
function _Container(x, y, width, height, children=Vector{GuiComponent}())
    return Container(x, y, width, height, children, ComponentState(), ContainerStyle(), Layout())
end

function Container()
    return Container(0.2, 0.2, 0.2, 0.2, GuiComponent[], ComponentState(), ContainerStyle(), Layout())
end

function handle_click(container::Container, mouse_state::MouseState)
    state = get_state(container)

    if inside_rectangular_component(container, mouse_state)
        if mouse_state.button_state[GLFW.MOUSE_BUTTON_LEFT] == IsPressed
            if !state.is_clicked
                state.is_clicked = true
                dispatch_event(container, :on_click)
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
            dispatch_event(container, :on_mouse_enter, mouse_state)
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
            dispatch_event(container, :on_mouse_leave, mouse_state)
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
    border_width_x = (border_width_px / window_width_px) * 2
    border_width_y = (border_width_px / window_height_px) * 2

    # Adjust container dimensions for padding_px
    padding_px = container.layout.padding_px
    padded_x = container.x + padding_px
    padded_y = container.y + padding_px
    padded_width = container.width - 2 * padding_px
    padded_height = container.height - 2 * padding_px

    # Draw the border if border_width > 0
    if border_width_px > 0.0
        # Generate vertices for the border rectangle
        border_positions, border_colors, border_elements = generate_rectangle(
            padded_x - border_width_x, padded_y - border_width_y,
            padded_width + 2 * border_width_x, padded_height + 2 * border_width_y,
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
        padded_x, padded_y, padded_width, padded_height, bg_color
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