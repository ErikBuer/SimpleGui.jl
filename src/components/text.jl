mutable struct TextStyle
    font_size_px::Float32
    font_color::Tuple{Float32,Float32,Float32,Float32}
    font_family::String
    font_weight::String
    font_style::String
    text_align::String
    layout::Layout
end

function TextStyle(; font_size_px=12.0, font_color=(0.0, 0.0, 0.0, 1.0), font_family="Arial", font_weight="normal", font_style="normal", text_align="left")
    return TextStyle(font_size_px, font_color, font_family, font_weight, font_style, text_align, Layout())
end

mutable struct Text <: AbstractGuiComponent
    text::String
    x::Float32
    y::Float32
    width::Float32
    height::Float32
    state::ComponentState
    style::ContainerStyle
end

function Text(x::Float32, y::Float32, text::String, style::TextStyle)
    return Text(x, y, ComponentState(), style)
end