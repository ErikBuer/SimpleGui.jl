abstract type AbstractView end

"""
    interpret_view(component::AbstractView, x::Float32, y::Float32, width::Float32, height::Float32, projection_matrix::Mat4{Float32})

Interpret the view of a GUI component.
This function is responsible for interpreting the view of a GUI component based on its layout and properties.
"""
function interpret_view(component::AbstractView, x::Float32, y::Float32, width::Float32, height::Float32, projection_matrix::Mat4{Float32})
    error("interpret_view not implemented for component of type $(typeof(component))")
end

"""
    apply_layout(component::AbstractView)

Apply layout to a GUI component and its children.
This function calculates and applies the layout to components.
The `interpret_view` function then uses the positions and sizes calculated by this function.
"""
function apply_layout(component::AbstractView)
    error("apply_layout is not implemented for $(typeof(component))")
end