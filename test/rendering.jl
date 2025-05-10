using SimpleGui
using ColorTypes

using TestItems


@testitem "Generate Container" begin
    using ColorTypes

    # Initialize the window (or headless context)
    window_state = initialize_window("", 400, 300)
    SimpleGui.update_window_size(window_state) # Only needed for headless context

    # Create and register components
    container = SimpleGui.Container()
    set_color(container, ColorTypes.RGB(0.3, 0.3, 0.6))
    register_component(window_state, container)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen(window_state, "test_output/test_screenshot.png", 400, 300)
end


@testitem "Draw Image" begin        # TODO image not rendered (need to be drawn through a component to work in this test environment)
    using ModernGL, GLFW, GLAbstraction
    const GLA = GLAbstraction

    # Initialize the window (or headless context)
    window_state = initialize_window("", 400, 300)
    SimpleGui.update_window_size(window_state) # Only needed for headless context


    img = SimpleGui.load_texture("images/logo.png")

    SimpleGui.draw_image(img, 0.0, 0.0, window_state.projection_matrix, scale=0.2f0)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen(window_state, "test_output/draw_image.png", 400, 300)
end


@testitem "Generate Text" begin
    # Initialize the window (or headless context)
    window_state = initialize_window("", 400, 300)
    SimpleGui.update_window_size(window_state) # Only needed for headless context

    # Create and register components
    button = SimpleGui.Text("Read Me")
    register_component(window_state, button)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen(window_state, "test_output/text_test.png", 400, 300)
end


@testitem "Generate Text Button" begin
    # Initialize the window (or headless context)
    window = initialize_window("", 400, 300)

    # Create and register components
    button = SimpleGui.Button("Click Me")
    register_component(window_state, button)

    # Save the screenshot using offscreen rendering
    SimpleGui.save_screenshot_offscreen(window_state, "test_output/text_button.png", 400, 300)
end


@testitem "Test orthographic Projection Matrix" begin
    projection_matrix = SimpleGui.get_orthographic_matrix(0.0, 1920.0, 1080.0, 0.0, -1.0, 1.0)

    vertex1 = Float32[0.0, 0.0, 0.0, 1.0]

    vertex_ndc = projection_matrix * vertex1
    @test vertex_ndc[1:2] == [-1.0, 1.0]

    vertex2 = Float32[1920/2, 1080/2, 0.0, 1.0]
    vertex_ndc2 = projection_matrix * vertex2
    @test vertex_ndc2[1:2] == [0.0, 0.0]
end