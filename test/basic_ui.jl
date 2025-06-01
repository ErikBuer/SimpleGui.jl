using SimpleGui
using ColorTypes

function main()
    # Define the UI structure
    ui = Container()

    window_state = initialize_window(ui, title="Simple GUI Example")

    # Run the GUI
    SimpleGui.run(window_state)
end


main()