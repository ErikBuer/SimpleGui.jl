using SimpleGui
using ColorTypes

using TestItems


@testitem "Generate Container" begin
    function MyApp()
        Row([
            Container(on_click=() -> println("Clicked on Container 1")),
            Container(),
            Column([Container(), Container(), Container(Container())], padding=0)
        ])
    end

    ui = MyApp()

    # Save a screenshot of the UI
    SimpleGui.save_screenshot_offscreen(ui, "test_output/ui_screenshot.png", 400, 300)
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