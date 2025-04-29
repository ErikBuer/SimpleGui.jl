mutable struct VerticalLayout <: AbstractGuiComponent
    x::Float32          # X position in NDC. Calculated value, not user input
    y::Float32          # Y position in NDC. Calculated value, not user input
    width::Float32      # Width in NDC. Calculated value, not user input
    height::Float32     # Width in NDC. Calculated value, not user input
    spacing::Float32    # Spacing between child components in pixels
    padding::Float32    # Padding around the layout in pixels
    children::Vector{AbstractGuiComponent}
end

mutable struct HorizontalLayout <: AbstractGuiComponent
    x::Float32          # X position in NDC. Calculated value, not user input
    y::Float32          # Y position in NDC. Calculated value, not user input
    width::Float32      # Width in NDC. Calculated value, not user input
    height::Float32     # Width in NDC. Calculated value, not user input
    spacing::Float32    # Spacing between child components in pixels
    padding::Float32    # Padding around the layout in pixels
    children::Vector{AbstractGuiComponent}
end

function apply_layout_common(layout, axis::Axis)
    parent_x = layout.x
    parent_y = layout.y
    parent_width = layout.width
    parent_height = layout.height
    padding = layout.padding
    spacing = layout.spacing

    # Adjust available space for padding
    available_width = parent_width - 2 * padding
    available_height = parent_height - 2 * padding

    # Track the current position
    current_x = parent_x + padding
    current_y = parent_y + parent_height - padding  # Start at the top for vertical layout

    for child in layout.children
        if axis == Vertical
            # Set child dimensions
            child.width = available_width
            child.height = child.height  # Keep the child's height as is
            # Position the child
            child.x = current_x
            current_y -= child.height + spacing
            child.y = current_y
        elseif axis == Horizontal
            # Set child dimensions
            child.width = child.width  # Keep the child's width as is
            child.height = available_height
            # Position the child
            child.y = current_y - available_height
            child.x = current_x
            current_x += child.width + spacing
        end
    end
end

function apply_layout(layout::VerticalLayout)
    apply_layout_common(layout, Vertical)
end

function apply_layout(layout::HorizontalLayout)
    apply_layout_common(layout, Horizontal)
end


function render(layout::VerticalLayout)
    apply_layout(layout)
    for child in layout.children
        render(child)
    end
end

function render(layout::HorizontalLayout)
    apply_layout(layout)
    for child in layout.children
        render(child)
    end
end