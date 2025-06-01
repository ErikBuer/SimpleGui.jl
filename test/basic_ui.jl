using SimpleGui
using ColorTypes

function main()
    # Define the UI structure

    function MyApp()
        Row([
            Container(),
            Container(),
            Column([Container(), Container(), Container(Container())], padding=0)
        ])
    end

    ui = MyApp()

    window_state = initialize_window(ui, title="Simple GUI Example")

    # Run the GUI
    SimpleGui.run(window_state)
end


main()