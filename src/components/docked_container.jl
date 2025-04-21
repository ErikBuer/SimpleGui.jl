"""
A DockedContainer is a GUI component that can be docked to one of the four sides of a parent container.
"""
mutable struct DockedContainer <: AbstractDockedComponent
    x::Float32          # X position in NDC. Calculated value, not user input
    y::Float32          # Y position in NDC. Calculated value, not user input
    width::Float32      # Width in NDC. Calculated value, not user input
    height::Float32     # Width in NDC. Calculated value, not user input
    children::Vector{AbstractGuiComponent}  # Child components
    state::ComponentState
    style::ContainerStyle
    layout::DockedLayout
end

function DockedContainer()
    return DockedContainer(0.2, 0.2, 0.2, 0.2, AbstractGuiComponent[], ComponentState(), ContainerStyle(), DockedLayout())
end