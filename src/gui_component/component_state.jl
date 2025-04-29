mutable struct ComponentState
    is_hovered::Bool
    is_clicked::Bool
    event_handlers::Dict{MouseEvent,Function}
    enabled_events::Dict{MouseEvent,Bool}
end

"""
Default constructor for ComponentState.
"""
function ComponentState()
    return ComponentState(false, false, Dict{MouseEvent,Function}(), Dict{MouseEvent,Bool}())
end

function get_state(component::AbstractGuiComponent)::ComponentState
    return component.state
end