include("SimpleGui.jl")
using .SimpleGui


function main()
    # Initialize the window
    window = initialize_window("Simple GUI Example", (1920, 1080))

    # Initialize shaders
    SimpleGui.initialize_shaders()


    main_container = SimpleGui._Container(-1.0, -1.0, 2.0, 2.0)
    main_container.layout.size_rule = FillParentArea

    # Create a container
    container = SimpleGui._Container(-0.5, -0.5, 1.0, 1.0)
    container.style.background_color = (0.3, 0.3, 0.6, 0.0)

    # Register event listeners
    register_event(container, OnClick, () -> println("Container clicked!"))
    register_event(container, OnMouseEnter, (mouse_state) -> println("Mouse entered at ($(mouse_state.x), $(mouse_state.y))"))


    # Create child components
    child1 = SimpleGui._Container(0.0, 0.0, 0.4, 0.4)
    child1.style.background_color = (0.6, 0.3, 0.3, 0.0)
    child2 = SimpleGui._Container(0.0, 0.0, 0.2, 0.2)
    child2.style.background_color = (0.3, 0.6, 0.3, 0.0)

    # Add children to the parent
    push!(container.children, child1)
    push!(container.children, child2)

    push!(main_container.children, container)

    # Register the container
    register_component(main_container)

    # Run the GUI
    SimpleGui.run(window)
end

main()