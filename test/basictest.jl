using SimpleGui

using ColorTypes

function main()
    # Initialize the window (or headless context)
    window = initialize_window("Headless GUI Example", (400, 300))

    # Create and register components
    container = SimpleGui._Container(-0.5, -0.5, 1.0, 1.0)
    set_color(container, ColorTypes.RGB(0.3, 0.3, 0.6))
    register_component(container)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen("test_screenshot.png", 400, 300)
end

main()