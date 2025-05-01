include("SimpleGui.jl")
using .SimpleGui

using GeometryBasics, ColorTypes

function main()
    # Initialize the window
    window = initialize_window("Simple GUI Example", (1920, 1080))

    # Initialize shaders
    SimpleGui.initialize_shaders()


    top_bar = DockedContainer()
    top_bar.layout.docking = DockTop
    register_component(top_bar)


    side_bar = DockedContainer()
    side_bar.layout.docking = DockLeft
    register_component(side_bar)


    # Create a container
    container = SimpleGui._Container(-0.5, -0.5, 1.0, 1.0)
    set_color(container, ColorTypes.RGB(0.3, 0.3, 0.6))

    # Register event listeners
    register_event(container, OnClick, () -> println("Container clicked!"))
    register_event(container, OnMouseEnter, (mouse_state) -> println("Mouse entered at ($(mouse_state.x), $(mouse_state.y))"))


    # Create child components
    child1 = SimpleGui._Container(0.0, 0.0, 0.4, 0.4)
    set_color(child1, Vec4(0.6, 0.3, 0.3, 1.0))
    child2 = SimpleGui._Container(0.0, 0.0, 0.2, 0.2)
    set_color(child2, ColorTypes.RGBA(0.3, 0.6, 0.3, 1.0))

    # Add children to the parent
    push!(container.children, child1)
    push!(container.children, child2)

    register_component(container)

    # Run the GUI
    SimpleGui.run(window)
end



main()