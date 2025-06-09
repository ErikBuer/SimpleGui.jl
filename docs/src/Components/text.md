# Text

``` @example TextExample
using Element
using Element: Text

function MyApp()
    Container(
        Text("Some Text")
    )
end

screenshot(MyApp, "text.png", 400, 150);
nothing #hide
```

![Text](text.png)
