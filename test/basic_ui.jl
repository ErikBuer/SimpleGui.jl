using SimpleGui
using SimpleGui: Text

function main()
    # Mutable state variable
    showImage = Ref(true)

    ui = Ref{AbstractView}(Empty())

    function MyApp()
        Row([
            Container(Text("Hello World")),
            Container(
                if showImage[]
                    Image("test/images/logo.png")
                else
                    Text("Click to show image")
                end,
                on_click=() -> (
                    println("Toggling image visibility...");
                    showImage[] = !showImage[];  # Update state
                    ui[] = MyApp()               # Update the UI reference
                )
            ),
            Column([
                    Container(),
                    Container(HorizontalSlider(0.0f0, 100.0f0, 50.0f0; on_change=(value) -> println("Slider value: $value"))),
                    Container(Container(on_click=() -> println("Clicked")))],
                padding=0
            )
        ])
    end

    ui[] = MyApp()

    # Run the GUI
    SimpleGui.run(ui, title="Dynamic UI Example")
end

main()