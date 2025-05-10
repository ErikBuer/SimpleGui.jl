# Docked Container

`DockedContainer` is a component for creating top bars and sidebars, Navbar, and the like.

``` @example DockedCointainer
using SimpleGui

# Initialize the window
window_state= initialize_window("Simple GUI Example", (400, 300))
SimpleGui.update_window_size(window_state) # Only needed for headless context # hide

top_bar = DockedContainer()
top_bar.layout.docking = DockTop
register_component(window_state, top_bar)


side_bar = DockedContainer()
side_bar.layout.docking = DockLeft
register_component(window_state, side_bar)

SimpleGui.save_screenshot_offscreen("docked_container.png", 400, 300) # hide
```

![Docked Container example](docked_container.png)
