export handle_click, handle_mouse_enter, handle_mouse_leave, render

mutable struct Container <: GuiComponent
    x::Float32
    y::Float32
    width::Float32
    height::Float32
    color::Tuple{Float32,Float32,Float32,Float32} # RGBA
    children::Vector{GuiComponent}  # Child components
    state::ComponentState           # Shared state
end

function handle_click(container::Container, mouse_x::Float64, mouse_y::Float64, button::GLFW.MouseButton, is_clicked::Bool)
    state = get_state(container)
    if mouse_x >= container.x && mouse_x <= container.x + container.width &&
       mouse_y >= container.y && mouse_y <= container.y + container.height
        if is_clicked == GLFW.PRESS && button == GLFW.MOUSE_BUTTON_LEFT
            if !state.is_clicked
                state.is_clicked = true
                dispatch_event(container, :on_click)
            end
        elseif !is_clicked
            state.is_clicked = false
        end
    end
end

function handle_mouse_enter(container::Container, mouse_x::Float64, mouse_y::Float64)
    state = get_state(container)
    if mouse_x >= container.x && mouse_x <= container.x + container.width &&
       mouse_y >= container.y && mouse_y <= container.y + container.height
        if !state.is_hovered
            state.is_hovered = true
            dispatch_event(container, :on_mouse_enter)
        end
    end
end

function handle_mouse_leave(container::Container, mouse_x::Float64, mouse_y::Float64)
    state = get_state(container)
    if !(mouse_x >= container.x && mouse_x <= container.x + container.width &&
         mouse_y >= container.y && mouse_y <= container.y + container.height)
        if state.is_hovered
            state.is_hovered = false
            dispatch_event(container, :on_mouse_leave)
        end
    end
end

# Constructor with default empty event handlers
function Container(x, y, width, height, color, children=Vector{GuiComponent}())
    return Container(x, y, width, height, color, children, ComponentState())
end

# Implement get_state for Container
function get_state(container::Container)::ComponentState
    return container.state
end

function render(container::Container)
    # Define the vertices of the rectangle
    vertex_positions = Point{2,Float32}[
        (container.x, container.y),  # Bottom-left
        (container.x + container.width, container.y),  # Bottom-right
        (container.x + container.width, container.y + container.height),  # Top-right
        (container.x, container.y + container.height)  # Top-left
    ]

    # Define the colors for each vertex
    vertex_colors = Vec{4,Float32}[
        Vec(container.color...),  # Bottom-left
        Vec(container.color...),  # Bottom-right
        Vec(container.color...),  # Top-right
        Vec(container.color...)   # Top-left
    ]

    # Define the element indices for two triangles
    elements = NgonFace{3,UInt32}[
        (0, 1, 2),  # First triangle
        (2, 3, 0)   # Second triangle
    ]

    # Generate buffers and vertex array
    buffers = GLA.generate_buffers(prog[], position=vertex_positions, color=vertex_colors)
    vao = GLA.VertexArray(buffers, elements)

    # Bind and draw
    GLA.bind(prog[])
    GLA.bind(vao)
    GLA.draw(vao)
    GLA.unbind(vao)
    GLA.unbind(prog[])
end