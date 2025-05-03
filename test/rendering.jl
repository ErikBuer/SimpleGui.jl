using SimpleGui
using ColorTypes

using TestItems


@testitem "Generate Container" begin
    using ColorTypes

    # Initialize the window (or headless context)
    window = initialize_window("Headless GUI Example", (400, 300))

    # Create and register components
    container = SimpleGui._Container(-0.5, -0.5, 1.0, 1.0)
    set_color(container, ColorTypes.RGB(0.3, 0.3, 0.6))
    register_component(container)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen("test_output/test_screenshot.png", 400, 300)
end


@testitem "Draw Image" begin        # TODO image not rendered
    using ModernGL, GLFW, GLAbstraction
    const GLA = GLAbstraction

    # Initialize the window (or headless context)
    window = initialize_window("Headless GUI Example", (800, 600))

    texture = SimpleGui.load_texture("images/logo.png")

    SimpleGui.draw_image(texture, -1.0f0, -1.0f0, scale=0.2f0)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen("test_output/draw_image.png", 800, 600)
end


@testitem "Generate Text" begin
    # Initialize the window (or headless context)
    window = initialize_window("Headless GUI Example", (400, 300))

    # Create and register components
    button = SimpleGui.Text("Read Me")
    register_component(button)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen("test_output/text_button.png", 400, 300)
end


@testitem "Generate Text Button" begin
    # Initialize the window (or headless context)
    window = initialize_window("Headless GUI Example", (400, 300))

    # Create and register components
    button = SimpleGui.Button("Click Me")
    register_component(button)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen("test_output/text_button.png", 400, 300)
end