@enum LayoutRule StackVertical StackHorizontal AlignCenter
@enum SizeRule FixedSize FillParentVertical FillParentHorizontal FillParentArea

mutable struct Layout
    layout_rule::LayoutRule
    size_rule::SizeRule
    padding::Float32
end

function Layout(; layout_rule=StackVertical, size_rule=FillParentHorizontal, padding=0.0)
    return Layout(layout_rule, size_rule, padding)
end

function apply_layout(component::GuiComponent)
    parent_x = component.x
    parent_y = component.y
    parent_width = component.width
    parent_height = component.height
    layout = component.layout

    # Track the current position for stacking
    current_x = parent_x + layout.padding
    current_y = parent_y + parent_height - layout.padding  # Start at the top of the parent

    for child in component.children
        # Adjust child size based on size_rule
        if child.layout.size_rule == FillParentHorizontal
            child.width = parent_width - 2 * layout.padding
        elseif child.layout.size_rule == FillParentVertical
            child.height = parent_height - 2 * layout.padding
        elseif child.layout.size_rule == FillParentArea
            # Fill both width and height of the parent
            child.width = parent_width - 2 * layout.padding
            child.height = parent_height - 2 * layout.padding
        elseif child.layout.size_rule == FixedSize
            # Keep the child's size as is (default behavior)
        end

        # Position the child based on layout_rule
        if layout.layout_rule == StackVertical
            # Stack children vertically
            child.x = parent_x + layout.padding
            current_y -= child.height + layout.padding
            child.y = current_y
        elseif layout.layout_rule == StackHorizontal
            # Stack children horizontally
            child.y = parent_y + layout.padding
            child.x = current_x
            current_x += child.width + layout.padding
        elseif layout.layout_rule == AlignCenter
            # Center the child horizontally and vertically
            child.x = parent_x + (parent_width - child.width) / 2
            child.y = parent_y + (parent_height - child.height) / 2
        end

        # Recursively apply layout to child components
        if isa(child, GuiComponent)
            apply_layout(child)
        end
    end
end