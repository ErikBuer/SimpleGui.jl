# Docked Container

``` @example DockedCointainer
using SimpleGui

# Initialize the window
window = initialize_window("Simple GUI Example", (400, 300))

top_bar = DockedContainer()
top_bar.layout.docking = DockTop
register_component(top_bar)


side_bar = DockedContainer()
side_bar.layout.docking = DockLeft
register_component(side_bar)

SimpleGui.save_screenshot_offscreen("docked_container.png", 400, 300) # hide
```

![Docked Container example](docked_container.png)
