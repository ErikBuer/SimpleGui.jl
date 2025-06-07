mutable struct TextStyle
    font_size_px::Float32
    font_color::Vec4{<:AbstractFloat}
    font_family::String
    font_weight::String
    font_style::String
    text_align::String
    layout::AlignedLayout
end

function TextStyle(; font_size_px=12.0, font_color=(0.0, 0.0, 0.0, 1.0), font_family="Arial", font_weight="normal", font_style="normal", text_align="left")
    return TextStyle(font_size_px, font_color, font_family, font_weight, font_style, text_align, AlignedLayout())
end

mutable struct Text <: AbstractGuiComponent
    text::String
    x::Float32              # X position in pixels. Calculated value, not user input
    y::Float32              # Y position in pixels. Calculated value, not user input
    width::Float32          # Width in pixels. Calculated value, not user input
    height::Float32         # Height in pixels. Calculated value, not user input
    style::TextStyle
end

function Text(x::Float32, y::Float32, text::String, style::TextStyle)
    return Text(text, x, y, 0.5, 0.5, style)
end

function Text(text::String)
    return Text(text, 0.0, 0.0, 0.0, 0.0, TextStyle())
end