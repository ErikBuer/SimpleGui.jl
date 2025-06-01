abstract type AbstractView end

abstract type AbstractGuiComponent end
"""
DockedContainer are docked to a specific side (e.g., left, right, top, bottom) and typically have fixed sizes in one dimension (e.g., width for vertical docking).
"""
abstract type AbstractDockedComponent <: AbstractGuiComponent end
"""
Aligned components (e.g., AlignCenter) are positioned relative to the parent, like buttons and input fields.
"""
abstract type AbstractAlignedComponent <: AbstractGuiComponent end

include("gui_component/utilities.jl")

# Placeholder functions for components
function handle_click(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_click is not implemented for $(typeof(component))")
end
function handle_context_menu(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_context_menu is not implemented for $(typeof(component))")
end
function handle_dbl_click(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_dbl_click is not implemented for $(typeof(component))")
end
function handle_mouse_enter(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_mouse_enter is not implemented for $(typeof(component))")
end
function handle_mouse_leave(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_mouse_leave is not implemented for $(typeof(component))")
end
function handle_mouse_move(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_mouse_move is not implemented for $(typeof(component))")
end
function handle_mouse_out(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_mouse_out is not implemented for $(typeof(component))")
end
function handle_mouse_over(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_mouse_over is not implemented for $(typeof(component))")
end
function handle_mouse_down(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_mouse_down is not implemented for $(typeof(component))")
end
function handle_mouse_up(component::AbstractGuiComponent, mouse_state::MouseState)
    error("handle_mouse_up is not implemented for $(typeof(component))")
end


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