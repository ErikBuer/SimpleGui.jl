include("SimpleGui.jl")
using .SimpleGui


function main()
    # Initialize the window
    window = initialize_window()

    # Initialize shaders
    SimpleGui.initialize_shaders()

    # Create a container
    container = Container(-0.5, -0.5, 1.0, 1.0)

    # Register event listeners
    register_event(container, :on_click, () -> println("Container clicked!"))
    register_event(container, :on_mouse_enter, (mouse_state) -> println("Mouse entered at ($(mouse_state.x), $(mouse_state.y))"))

    # Register the container
    register_component(container)

    # Run the GUI
    SimpleGui.run(window)
end

main()