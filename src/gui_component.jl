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
export Alignement, StackVertical, StackHorizontal, AlignCenter
export SizeRule, FillParentVertical, FillParentHorizontal, FillParentArea
export Docking, DockTop, DockBottom, DockLeft, DockRight


"""
    register_component(component::AbstractGuiComponent)

Register a GUI component to the global list of components.
This function is used to keep track of all components (on the top level) that need to be rendered and updated.
"""
function register_component(component::AbstractGuiComponent)
    push!(components, component)
end

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
    render(component::AbstractGuiComponent)

Renders the given component and its children based on the positions and sizes calculated by `apply_layout`.

Responsibilities:
- Draw the component itself (e.g., background, borders, etc.).
- Recursively render the component's children.

This function assumes that `apply_layout` has already been called to calculate the positions and sizes.
"""
function render(component::AbstractGuiComponent)
    error("render is not implemented for $(typeof(component))")
end
