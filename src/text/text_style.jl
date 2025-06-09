mutable struct TextStyle
    font::FreeTypeAbstraction.FTFont
    size_px::Int
    color::Vec4{Float32}  # RGBA color
end

function TextStyle(;
    font_name::String="",
    font_path::String=joinpath(@__DIR__, "../../assets/fonts/FragmentMono-Regular.ttf"),
    size_px=16,
    color=Vec{4,Float32}(0.0, 0.0, 0.0, 1.0),
)
    if font_name != ""
        font = FreeTypeAbstraction.findfont(font_name)
    elseif font_path != ""
        font = FreeTypeAbstraction.try_load(font_path)
    else
        error("Either font_name or font_path must be provided.")
    end
    return TextStyle(font, size_px, color)
end