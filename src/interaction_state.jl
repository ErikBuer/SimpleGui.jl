mutable struct InteractionState
    hovered_id::Union{Nothing,String}  # ID of the currently hovered component
    focused_id::Union{Nothing,String}  # ID of the currently focused component
    clicked_id::Union{Nothing,String}  # ID of the currently clicked component
end

function update_interaction_state(component::AbstractView, mouse_state::MouseState, x::Float32, y::Float32, width::Float32, height::Float32)::InteractionState
    # TODO
end