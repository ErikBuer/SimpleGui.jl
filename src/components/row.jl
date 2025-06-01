struct RowView <: AbstractView
    children::Vector{AbstractView}
    padding::Float32 # Padding around the row
    spacing::Float32 # Space between children
end

function Row(children::Vector{<:AbstractView}; padding=10.0, spacing=10.0)
    return RowView(children, padding, spacing)
end

function apply_layout(view::RowView, x::Float32, y::Float32, width::Float32, height::Float32)
    # Adjust the layout area to account for the global padding
    padded_x = x + view.padding
    padded_y = y + view.padding
    padded_width = width - 2 * view.padding
    padded_height = height - 2 * view.padding

    # Handle the case where there are no children
    if isempty(view.children)
        return []
    end

    # Calculate the width available for each child
    total_spacing = (length(view.children) - 1) * view.spacing
    child_width = (padded_width - total_spacing) / length(view.children)
    child_x = padded_x
    child_layouts = []

    # Calculate layout for each child
    for child in view.children
        push!(child_layouts, (child_x, padded_y, child_width, padded_height))
        child_x += child_width + view.spacing
    end

    return child_layouts
end

function interpret_view(view::RowView, x::Float32, y::Float32, width::Float32, height::Float32, projection_matrix::Mat4{Float32})
    # Get the layout for the immediate children
    child_layouts = apply_layout(view, x, y, width, height)

    # Render each child using the calculated layout
    for (child, (child_x, child_y, child_width, child_height)) in zip(view.children, child_layouts)
        interpret_view(child, child_x, child_y, child_width, child_height, projection_matrix)
    end
end