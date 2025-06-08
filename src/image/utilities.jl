function load_texture(file_path::String)::GLAbstraction.Texture
    try
        # Load the image using FileIO
        img = FileIO.load(file_path)  # Returns a Matrix or IndirectArray

        # If the image is an IndirectArray, materialize it into a standard array
        if img isa IndirectArrays.IndirectArray
            @debug("Materializing IndirectArray into a standard array...")
            img = img.values[img.index]
        end

        # Create a GLAbstraction texture
        texture = GLA.Texture(img;
            minfilter=:linear,
            magfilter=:linear,
            x_repeat=:clamp_to_edge,
            y_repeat=:clamp_to_edge
        )

        return texture
    catch e
        @warn("Failed to load image at path '$file_path': $e")
        @warn("Using a placeholder texture instead.")

        # Create a placeholder texture (e.g., a solid color or empty texture)
        placeholder_img = fill(0.5f0, 64, 64)  # Gray 64x64 texture
        return GLA.Texture(placeholder_img;
            minfilter=:linear,
            magfilter=:linear,
            x_repeat=:clamp_to_edge,
            y_repeat=:clamp_to_edge
        )
    end
end

function load_textures(root_view::AbstractView)
    if root_view isa ImageView
        # Load the texture from the image path
        root_view.texture = load_texture(root_view.image_path)
    elseif root_view isa ContainerView
        # Recursively load textures for child components
        load_textures(root_view.child)
    elseif root_view isa RowView || root_view isa ColumnView
        # Recursively load textures for all children
        for child in root_view.children
            load_textures(child)
        end
    end
end