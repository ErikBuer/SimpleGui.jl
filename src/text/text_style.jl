mutable struct TextStyle
    font::FreeTypeAbstraction.FTFont
    size_px::Int
    color::Vec4{Float32}  # RGBA color
end

function TextStyle(;
    font=FreeTypeAbstraction.findfont("arial"),
    size_px=16,
    color=Vec{4,Float32}(0.0, 0.0, 0.0, 1.0),
)
    return TextStyle(font, size_px, color)
end