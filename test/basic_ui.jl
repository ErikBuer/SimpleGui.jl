using SimpleGui
using ColorTypes

function main()
    # Define the UI structure

    function MyApp()
        Row([
            Container(on_click=() -> println("Clicked on Container 1")),
            Container(),
            Column([Container(), Container(), Container(Container(on_click=() -> println("Clicked")))], padding=0)
        ])
    end

    ui = MyApp()

    # Run the GUI
    SimpleGui.run(ui, title="SimpleGUI Example")
end


main()