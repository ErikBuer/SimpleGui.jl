# User interaction

``` @example InteractionExample
using Element

function MyApp()
    Container( on_click=() -> println("Clicked") )
end
```
