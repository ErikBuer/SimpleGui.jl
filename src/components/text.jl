struct TextView <: AbstractView
    text::String
    style::TextStyle
end

function Text(text::String; style=TextStyle())
    return TextView(text, style)
end

function apply_layout(view::TextView, x::Float32, y::Float32, width::Float32, height::Float32)
    # Text layout is simple: it occupies the entire area provided
    return (x, y, width, height)
end

function interpret_view(view::TextView, x::Float32, y::Float32, width::Float32, height::Float32, projection_matrix::Mat4{Float32})
    # Extract style properties
    font = view.style.font
    size_px = view.style.size_px
    color = view.style.color

    # Render the text using draw_text with positional arguments
    draw_text(
        font,                # Font face
        view.text,           # Text string
        x,                   # X position
        y,                   # Y position
        size_px,             # Text size
        projection_matrix,   # Projection matrix
        #color                # Text color
    )
end