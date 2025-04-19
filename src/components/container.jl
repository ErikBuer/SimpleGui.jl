mutable struct Container <: GuiComponent
    x::Float32
    y::Float32
    width::Float32
    height::Float32
    color::Tuple{Float32,Float32,Float32,Float32} # RGBA
    children::Vector{GuiComponent} # Child components (e.g., other Containers, Buttons, etc.)
    on_click::Function # Callback function for click events
end

function handle_click(container::Container, mouse_x::Float64, mouse_y::Float64, button::GLFW.MouseButton, action::GLFW.Action)
    # Check if the mouse click is within the container's bounds
    if mouse_x >= container.x && mouse_x <= container.x + container.width &&
       mouse_y >= container.y && mouse_y <= container.y + container.height &&
       action == GLFW.PRESS && button == GLFW.MOUSE_BUTTON_LEFT
        # Execute the on_click callback if defined
        if container.on_click !== nothing
            container.on_click()
        end
    end
end

function render_component(container::Container)
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