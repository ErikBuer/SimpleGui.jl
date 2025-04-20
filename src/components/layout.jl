@enum AlignmentType AlignCenter CenterHorizontal CenterVertical AlignLeft AlignRight AlignTop AlignBottom


mutable struct Layout
    alignment::AlignmentType
    padding::Float32
end

function Layout(; alignment=AlignCenter, padding=0.0)
    return Layout(alignment, padding)
end

function apply_layout(component::GuiComponent)
    parent_x = component.x
    parent_y = component.y
    parent_width = component.width
    parent_height = component.height
    layout = component.layout

    # Track the current position for stacking
    current_y = parent_y + parent_height  # Start at the top of the parent
    current_x = parent_x  # Start at the left of the parent

    for child in component.children
        if layout.alignment == AlignCenter
            # Center the child horizontally and vertically
            child.x = parent_x + (parent_width - child.width) / 2
            child.y = parent_y + (parent_height - child.height) / 2
        elseif layout.alignment == CenterHorizontal
            # Center the child horizontally
            child.x = parent_x + (parent_width - child.width) / 2
        elseif layout.alignment == CenterVertical
            # Center the child vertically
            child.y = parent_y + (parent_height - child.height) / 2
        elseif layout.alignment == AlignLeft
            # Align the child to the left
            child.x = parent_x + layout.padding
        elseif layout.alignment == AlignRight
            # Align the child to the right
            child.x = parent_x + parent_width - child.width - layout.padding
        elseif layout.alignment == AlignTop
            # Align the child to the top
            child.y = parent_y + parent_height - child.height - layout.padding
        elseif layout.alignment == AlignBottom
            # Align the child to the bottom
            child.y = parent_y + layout.padding
        else
            # Default stacking: Place children vertically below each other
            child.x = parent_x + layout.padding
            current_y -= child.height + layout.padding  # Move down for the next child
            child.y = current_y
        end

        # Recursively apply layout to child components
        if isa(child, GuiComponent)
            apply_layout(child)
        end
    end
end