using FreeTypeAbstraction
using ColorTypes

using Plots

function render_text_with_plot(text::String, font_face, font_size::Integer)
    # Canvas dimensions
    canvas_width = 1024
    canvas_height = 256
    canvas = zeros(UInt8, canvas_height, canvas_width)

    # Render the string into the canvas
    renderstring!(
        canvas,
        text,
        font_face,
        font_size,
        canvas_height ÷ 2,  # Center vertically
        canvas_width ÷ 2;   # Center horizontally
        halign=:hcenter,
        valign=:vcenter,
        fcolor=typemax(UInt8),  # Foreground color (white for UInt8)
        bcolor=nothing          # Transparent background
    )

    # Convert the canvas to a Float64 array for visualization
    img = Gray.(convert.(Float64, canvas) ./ 255)

    # Plot the image using Plots.jl
    plot(img, color=:gray, legend=false, title="Rendered Text")
end

# Example usage
font_face = findfont("arial")
if font_face === nothing
    error("Font not found!")
end

render_text_with_plot("Hello, FreeType!", font_face, 48)