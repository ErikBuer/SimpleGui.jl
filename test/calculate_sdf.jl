using FreeTypeAbstraction
using GLMakie
using SimpleGui

# Load a font using FreeTypeAbstraction
font_face = findfont("arial")
if font_face === nothing
    error("Font not found!")
end

# Define the character and pixel size
char = '?'
pixelsize = 64

# Render the glyph and get its bitmap
bitmap, extent = renderface(font_face, char, pixelsize)

# Convert the bitmap to a binary array for plotting
bitmap_bool = bitmap .> 128

# Convert BitMatrix to Matrix{Bool}
bitmap_bool_matrix = Matrix(bitmap_bool)

# Plot the bitmap
fig = Figure()
ax = Axis(fig[1, 1], title="Glyph Bitmap for '$char'")
image!(ax, bitmap_bool)#, colormap=:grays)
fig


sdf_matrix = SimpleGui.calculate_signed_distance_field(bitmap_bool_matrix)

# Visualize the SDF
ax = Axis(fig[1, 2], title="Signed Distance Field for '$char'")
image!(ax, sdf_matrix, colormap=:viridis)

fig