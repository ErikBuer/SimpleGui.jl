using SimpleGui

using ColorTypes

function main()
    # Initialize the window
    window_state = initialize_window("Simple GUI Example", 1920, 1080)


    top_bar = DockedContainer()
    top_bar.layout.docking = DockTop
    register_component(window_state, top_bar)


    side_bar = DockedContainer()
    side_bar.layout.docking = DockLeft
    register_component(window_state, side_bar)


    # Create a container
    container = SimpleGui.Container()
    set_color(container, ColorTypes.RGB(0.3, 0.3, 0.6))

    # Register event listeners

    register_event(container, OnClick, () -> println("Container clicked!"))
    register_event(container, OnMouseEnter, (mouse_state) -> println("Mouse entered at ($(mouse_state.x), $(mouse_state.y))"))


    # Create child components
    child1 = SimpleGui.Container()
    set_color(child1, [0.6, 0.3, 0.3, 1.0])
    child2 = SimpleGui.Container()
    set_color(child2, ColorTypes.RGBA(0.3, 0.6, 0.3, 1.0))

    # Add children to the parent
    #push!(container.children, child1)
    #push!(container.children, child2)

    register_component(window_state, container)

    # Run the GUI
    SimpleGui.run(window_state)
end


main()