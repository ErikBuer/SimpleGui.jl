# Docked Container

`DockedContainer` is a component for creating top bars and sidebars, Navbar, and the like.

``` @example DockedCointainer
using SimpleGui

function MyApp()
    Row([
        Container(on_click=() -> println("Clicked on Container 1")),
        Container(),
        Column([Container(), Container(), Container(Container())], padding=0)
    ])
end

ui = MyApp()

# Save a screenshot of the UI
SimpleGui.save_screenshot_offscreen(ui, "ui_screenshot.png", 400, 300)
```

![UI example](ui_screenshot.png)
