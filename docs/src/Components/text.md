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

``` @example WrappingExample
using Element
using Element: Text

function MyApp()
    Container(
        Text("Some strings may be too long to fit, and must be drawn over multiple lines.")
    )
end

screenshot(MyApp, "text_wrap.png", 400, 150);
nothing #hide
```

![Text wrapping](text_wrap.png)
