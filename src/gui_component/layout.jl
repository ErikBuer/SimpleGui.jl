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
    dc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat

Convert NDC scale to pixels.

```jldoctest
julia> ndc_to_px(0.5, 800)
200.0
```
"""
function ndc_to_px(dim::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (dim / 2) * dim_px
end

"""
    px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat

Convert pixel to NDC scale.

```jldoctest
julia> px_to_ndc(200.0, 800)
0.5
```
"""
function px_to_ndc(px::AbstractFloat, dim_px::Integer)::AbstractFloat
    return (px / dim_px) * 2
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

    # Convert padding from pixels to NDC
    padding_x = (layout.padding_px / window_info.width_px) * 2  # Horizontal padding in NDC
    padding_y = (layout.padding_px / window_info.height_px) * 2 # Vertical padding in NDC

    # Track the current position for stacking
    current_x = parent_x
    current_y = parent_y + parent_height

    for child in component.children

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