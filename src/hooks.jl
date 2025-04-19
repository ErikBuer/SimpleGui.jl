mutable struct State{T}
    value::T
end

function use_state(initial_value)
    state = State(initial_value)
    return state, (new_value) -> (state.value = new_value)
end