mutable struct ComponentState
    is_hovered::Bool
    is_clicked::Bool
    event_handlers::Dict{Symbol,Function}
    enabled_events::Dict{Symbol,Bool}
end

"""
Default constructor for ComponentState.
"""
function ComponentState()
    return ComponentState(false, false, Dict{Symbol,Function}(), Dict{Symbol,Bool}())
end

function get_state(component::GuiComponent)::ComponentState
    return component.state
end