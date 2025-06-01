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

include("gui_component/layout.jl")
export AlignedLayout, DockedLayout
export Alignement, AlignCenter
export SizeRule, FillParentHorizontal, FillParentVertical, FillParentArea, SizeToContent, Fixed
export Docking, DockTop, DockBottom, DockLeft, DockRight
export set_color

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


function interpret_view(component::AbstractView, x::Float32, y::Float32, width::Float32, height::Float32, projection_matrix::Mat4{Float32})
    error("interpret_view not implemented for component of type $(typeof(component))")
end


"""
    render(component::AbstractGuiComponent)

Renders the given component and its children based on the positions and sizes calculated by `apply_layout`.

Responsibilities:
- Draw the component itself (e.g., background, borders, etc.).
- Recursively render the component's children.

This function assumes that `apply_layout` has already been called to calculate the positions and sizes.
"""
function render(component::AbstractGuiComponent, projection_matrix::Mat4{Float32})
    error("render is not implemented for $(typeof(component))")
end


function set_color(component::AbstractView, color::AbstractVector{<:Real})
    if 4 < length(color)
        error("Color vector must have 4 elements (RGBA).")
    elseif length(color) == 3
        # If only RGB is provided, set alpha to 1.0
        color = [color; 1.0]
    end
    component.style.background_color = Vec4(color...)
end

function set_color(component::AbstractView, color::ColorTypes.RGBA{<:AbstractFloat})
    # Convert RGBA to Vec4
    color_vec = Vec4(color.r, color.g, color.b, color.alpha)
    component.style.background_color = color_vec
end

function set_color(component::AbstractView, color::ColorTypes.RGB{<:AbstractFloat})
    # Convert RGB to Vec4
    color_vec = Vec4(color.r, color.g, color.b, 1.0)
    component.style.background_color = color_vec
end