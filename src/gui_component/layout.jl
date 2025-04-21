@enum Alignement StackVertical StackHorizontal AlignCenter                  # TODO change to just alignements, stacking is something else
@enum SizeRule FillParentVertical FillParentHorizontal FillParentArea
@enum Docking DockTop DockBottom DockLeft DockRight

@enum Axis begin
    Vertical
    Horizontal
end

"""
Layout struct for GUI components.
This struct defines the layout properties for a GUI component, including the layout rule, size rule, and padding_px.
"""
mutable struct AlignedLayout
    alignement::Alignement
    size_rule::SizeRule
    padding_px::Float32     # TODO fix
end

function AlignedLayout(; alignement=StackVertical, size_rule=FillParentHorizontal, padding_px=10.0)
    return AlignedLayout(alignement, size_rule, padding_px)
end

"""
Layout struct for docked components.
This struct defines the layout properties for a docked component, including the docking position and fixed size.
"""
mutable struct DockedLayout
    docking::Docking        # Docking position (DockTop, DockBottom, DockLeft, DockRight)
    size_px::Float32        # Fixed size (width for vertical docking, height for horizontal docking)
end

function DockedLayout(; docking=DockLeft, size_px=300.0)
    return DockedLayout(docking, size_px)
end


"""
    apply_layout(component::AbstractGuiComponent)

Apply layout to a GUI component and its children.
This function calculates and applies the layout to components.
The `render` function then uses the positions and sizes calculated by this function.

The default layout method.
Certain components may have their own layout methods, which will override this one.
"""
function apply_layout(component::AbstractGuiComponent)
    parent_x = component.x
    parent_y = component.y
    parent_width = component.width
    parent_height = component.height
    layout = component.layout

    # Track the current position for stacking
    current_x = parent_x
    current_y = parent_y + parent_height

    for child in component.children

        if isa(child, AbstractDockedComponent)

            # Apply docking layout and adjust parent dimensions for following children
            if child.layout.docking == DockTop
                size_ndc = px_to_ndc(child.layout.size_px, window_info.height_px)

                child.x = parent_x
                child.y = parent_y + parent_height - size_ndc
                child.width = parent_width
                child.height = size_ndc

                parent_height -= size_ndc
            elseif child.layout.docking == DockBottom
                size_ndc = px_to_ndc(child.layout.size_px, window_info.height_px)

                child.x = parent_x
                child.y = parent_y
                child.width = parent_width
                child.height = size_ndc

                parent_height -= size_ndc
                parent_y += size_ndc
            elseif child.layout.docking == DockLeft
                size_ndc = px_to_ndc(child.layout.size_px, window_info.width_px)

                child.x = parent_x
                child.y = parent_y
                child.width = size_ndc
                child.height = parent_height

                parent_width -= size_ndc
                parent_x += size_ndc
            elseif child.layout.docking == DockRight
                size_ndc = px_to_ndc(child.layout.size_px, window_info.width_px)

                child.x = parent_x + parent_width - size_ndc
                child.y = parent_y
                child.width = size_ndc
                child.height = parent_height

                parent_width -= size_ndc
            end

            continue  # Skip to the next iteration for docked components
        end

        child_padding_x = px_to_ndc(child.layout.padding_px, window_info.width_px)
        child_padding_y = px_to_ndc(child.layout.padding_px, window_info.height_px)

        # Adjust child size based on size_rule
        if child.layout.size_rule == FillParentHorizontal
            child.width = parent_width - 2 * child_padding_x
        elseif child.layout.size_rule == FillParentVertical
            child.height = parent_height - 2 * child_padding_y
        elseif child.layout.size_rule == FillParentArea
            # Fill both width and height of the parent
            child.width = parent_width - 2 * child_padding_x
            child.height = parent_height - 2 * child_padding_y
        end

        # Position the child based on alignement
        if layout.alignement == StackVertical
            # Stack children vertically
            child.x = parent_x + child_padding_x
            current_y -= child.height + child_padding_y
            child.y = current_y
        elseif layout.alignement == StackHorizontal
            # Stack children horizontally
            child.y = parent_y + child_padding_y
            child.x = current_x
            current_x += child.width + child_padding_x
        elseif layout.alignement == AlignCenter
            # Center the child horizontally and vertically
            child.x = parent_x + (parent_width - child.width) / 2
            child.y = parent_y + (parent_height - child.height) / 2
        end
    end
end