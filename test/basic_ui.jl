using SimpleGui
using SimpleGui: Text

function main()

    function MyApp()
        Row([
            Container(Text("Hello World"), on_click=() -> println("Clicked on Container 1")),
            Container(),
            Column([Container(), Container(), Container(Container(on_click=() -> println("Clicked")))], padding=0)
        ])
    end

    ui = MyApp()

    # Run the GUI
    SimpleGui.run(ui, title="SimpleGUI Example")
    #SimpleGui.save_screenshot_offscreen(ui, "ui_screenshot.png", 400, 300)
end


main()