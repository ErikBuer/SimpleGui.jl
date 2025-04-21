@enum LayoutRule StackVertical StackHorizontal AlignCenter
@enum SizeRule FillParentVertical FillParentHorizontal FillParentArea
# TODO @enum DockRule DockTop DockBottom DockLeft DockRight DockFill

"""
Layout struct for GUI components.
This struct defines the layout properties for a GUI component, including the layout rule, size rule, and padding_px.
"""
mutable struct Layout
    layout_rule::LayoutRule
    size_rule::SizeRule
    padding_px::Float32     # TODO fix
end

function Layout(; layout_rule=StackVertical, size_rule=FillParentHorizontal, padding_px=0.0)
    return Layout(layout_rule, size_rule, padding_px)
end

"""
Apply layout to a GUI component and its children.
This function applies the layout properties defined in the component's layout field.

The default layout method.
Certain components may have their own layout methods, which will override this one.
"""
function apply_layout(component::GuiComponent)
    parent_x = component.x
    parent_y = component.y
    parent_width = component.width
    parent_height = component.height
    layout = component.layout

    # Convert padding from pixels to NDC
    padding_x = (layout.padding_px / window_info.width_px) * 2  # Horizontal padding in NDC
    padding_y = (layout.padding_px / window_info.height_px) * 2 # Vertical padding in NDC

    # Track the current position for stacking
    current_x = parent_x + padding_x
    current_y = parent_y + parent_height - padding_y  # Start at the top of the parent

    for child in component.children
        # Adjust child size based on size_rule
        if child.layout.size_rule == FillParentHorizontal
            child.width = parent_width - 2 * padding_x
        elseif child.layout.size_rule == FillParentVertical
            child.height = parent_height - 2 * padding_y
        elseif child.layout.size_rule == FillParentArea
            # Fill both width and height of the parent
            child.width = parent_width - 2 * padding_x
            child.height = parent_height - 2 * padding_y
        end

        # Position the child based on layout_rule
        if layout.layout_rule == StackVertical
            # Stack children vertically
            child.x = parent_x + padding_x
            current_y -= child.height + padding_y
            child.y = current_y
        elseif layout.layout_rule == StackHorizontal
            # Stack children horizontally
            child.y = parent_y + padding_y
            child.x = current_x
            current_x += child.width + padding_x
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