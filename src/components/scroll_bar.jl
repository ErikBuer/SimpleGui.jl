mutable struct ScrollBar <: AbstractDockedComponent
    width::Float32          # Width of the scroll bar in pixels
    axis::Axis              # Axis of the scroll bar (Vertical or Horizontal)
    scroll_position::Float32  # Current scroll position (0.0 to 1.0)
    handle_size::Float32    # Size of the draggable handle in pixels
    parent::AbstractGuiComponent    # The parent component this scroll bar is attached to
end

# Constructor with default values
function ScrollBar(parent::AbstractGuiComponent; width=10.0, axis=Vertical, handle_size=50.0)
    return ScrollBar(width, axis, 0.0, handle_size, parent)
end

function apply_layout(scrollbar::ScrollBar)
    parent = scrollbar.parent

    if scrollbar.axis == Vertical
        # Vertical scroll bar (docked to the right)
        scrollbar.x = parent.x + parent.width - scrollbar.width
        scrollbar.y = parent.y
        scrollbar.width = scrollbar.width
        scrollbar.height = parent.height
    elseif scrollbar.axis == Horizontal
        # Horizontal scroll bar (docked to the bottom)
        scrollbar.x = parent.x
        scrollbar.y = parent.y
        scrollbar.width = parent.width
        scrollbar.height = scrollbar.width
    end
end

function render(scrollbar::ScrollBar)
    # Render the scroll bar background
    draw_rectangle(scrollbar.x, scrollbar.y, scrollbar.width, scrollbar.height, (0.8, 0.8, 0.8, 1.0))

    # Calculate the handle's position and size
    if scrollbar.axis == Vertical
        handle_x = scrollbar.x
        handle_y = scrollbar.y + (scrollbar.height - scrollbar.handle_size) * scrollbar.scroll_position
        handle_width = scrollbar.width
        handle_height = scrollbar.handle_size
    elseif scrollbar.axis == Horizontal
        handle_x = scrollbar.x + (scrollbar.width - scrollbar.handle_size) * scrollbar.scroll_position
        handle_y = scrollbar.y
        handle_width = scrollbar.handle_size
        handle_height = scrollbar.height
    end

    # Render the handle
    draw_rectangle(handle_x, handle_y, handle_width, handle_height, (0.5, 0.5, 0.5, 1.0))
end

function handle_scroll_interaction(scrollbar::ScrollBar, mouse_state::MouseState)
    if scrollbar.axis == Vertical
        # Vertical scroll bar
        handle_x = scrollbar.x
        handle_y = scrollbar.y + (scrollbar.height - scrollbar.handle_size) * scrollbar.scroll_position
        handle_width = scrollbar.width
        handle_height = scrollbar.handle_size

        if inside_rectangular_component(handle_x, handle_y, handle_width, handle_height, mouse_state)
            if mouse_state.button_state[GLFW.MOUSE_BUTTON_LEFT] == IsPressed
                # Calculate the new scroll position based on the mouse's Y position
                relative_y = mouse_state.y - scrollbar.y
                scrollbar.scroll_position = clamp(relative_y / (scrollbar.height - scrollbar.handle_size), 0.0, 1.0)
            end
        end
    elseif scrollbar.axis == Horizontal
        # Horizontal scroll bar
        handle_x = scrollbar.x + (scrollbar.width - scrollbar.handle_size) * scrollbar.scroll_position
        handle_y = scrollbar.y
        handle_width = scrollbar.handle_size
        handle_height = scrollbar.height

        if inside_rectangular_component(handle_x, handle_y, handle_width, handle_height, mouse_state)
            if mouse_state.button_state[GLFW.MOUSE_BUTTON_LEFT] == IsPressed
                # Calculate the new scroll position based on the mouse's X position
                relative_x = mouse_state.x - scrollbar.x
                scrollbar.scroll_position = clamp(relative_x / (scrollbar.width - scrollbar.handle_size), 0.0, 1.0)
            end
        end
    end
end

function update_parent_scroll(scrollbar::ScrollBar)
    parent = scrollbar.parent

    if scrollbar.axis == Vertical
        # Update the parent's vertical scroll position
        parent.y = -scrollbar.scroll_position * (parent.height - parent.layout.padding_px)
    elseif scrollbar.axis == Horizontal
        # Update the parent's horizontal scroll position
        parent.x = -scrollbar.scroll_position * (parent.width - parent.layout.padding_px)
    end
end