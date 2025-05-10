mutable struct ButtonStyle
    background_color::Vec4{<:AbstractFloat} #RGBA color
    border_color::Vec4{<:AbstractFloat} #RGBA color
    border_width_px::Float32
end

function ButtonStyle(;
    background_color=Vec4{Float32}(0.8f0, 0.8f0, 0.8f0, 1.0f0),
    border_color=Vec4{Float32}(0.0f0, 0.0f0, 0.0f0, 1.0f0),
    border_width_px=1.0f0)
    return ButtonStyle(background_color, border_color, border_width_px)
end

"""
The `Button` struct represents a button component that can contain other components.
"""
mutable struct Button <: AbstractAlignedComponent
    x::Float32          # X position in pixels. Calculated value, not user input
    y::Float32          # Y position in pixels. Calculated value, not user input
    width::Float32      # Width in pixels. Calculated value, not user input
    height::Float32     # Width in pixels. Calculated value, not user input
    children::Vector{AbstractGuiComponent}  # Child components
    state::ComponentState
    style::ButtonStyle
    layout::AlignedLayout
    text::String
    text_style::TextStyle
end

# Constructor for internal use
function _Button(x, y, width, height, children=Vector{AbstractGuiComponent}())
    return Button(x, y, width, height, children, ComponentState(), ButtonStyle(), AlignedLayout())
end

"""
Button constructor.
"""
function Button(button_text::String)
    return Button(0.2, 0.2, 0.2, 0.2, AbstractGuiComponent[], ComponentState(), ButtonStyle(), AlignedLayout(size_rule=SizeToContent))


end

function handle_click(component::Button, mouse_state::MouseState)
    state = get_state(component)

    if inside_rectangular_component(component, mouse_state)
        if mouse_state.button_state[GLFW.MOUSE_BUTTON_LEFT] == IsPressed
            if !state.is_clicked
                state.is_clicked = true
                dispatch_event(component, OnClick)
            end
        elseif state.is_clicked
            state.is_clicked = false
        end
    end
end

function handle_mouse_enter(component::Button, mouse_state::MouseState)
    state = get_state(component)
    if inside_rectangular_component(component, mouse_state)
        if !state.is_hovered
            state.is_hovered = true
            dispatch_event(component, OnMouseEnter, mouse_state)
        end
    else
        if state.is_hovered
            state.is_hovered = false
        end
    end
end

function handle_mouse_leave(component::Button, mouse_state::MouseState)
    state = get_state(component)
    if !(inside_rectangular_component(component, mouse_state))
        if state.is_hovered
            state.is_hovered = false
            dispatch_event(component, OnMouseLeave, mouse_state)
        end
    end
end

function handle_mouse_over(component::Button, mouse_state::MouseState)
    state = get_state(component)

    # Check if the mouse is inside the component's bounds
    if inside_rectangular_component(component, mouse_state)
        # Dispatch the OnMouseOver event
        dispatch_event(component, OnMouseOver, mouse_state)
    end
end

function render(component::Button)
    # Apply layout to position child components
    apply_layout(component)

    # Fetch the window dimensions from the global window_info
    window_width_px = window_info.width_px
    window_height_px = window_info.height_px

    # Extract style properties
    bg_color = component.style.background_color
    border_color = component.style.border_color
    border_width_px = component.style.border_width_px


    # Convert border width from pixels to NDC
    # border_width_x = px_to_ndc(border_width_px, window_width_px)
    # border_width_y = px_to_ndc(border_width_px, window_height_px)

    # Convert padding from pixels to NDC
    padding_px = component.layout.padding_px
    padding_x = px_to_ndc(padding_px, window_width_px)
    padding_y = px_to_ndc(padding_px, window_height_px)

    # Adjust component dimensions for padding
    padded_x = component.x + padding_x
    padded_y = component.y + padding_y
    padded_width = component.width - 2 * padding_x
    padded_height = component.height - 2 * padding_y

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
    for child in component.children
        render(child)
    end
end