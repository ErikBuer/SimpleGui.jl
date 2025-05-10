using LinearAlgebra

# SDF calculation
function calculate_signed_distance_field(image::Matrix{Bool}, metric::Function=euclidean)::Matrix{Float64}
    rows, cols = size(image)
    sdf_matrix = fill(0.0, rows, cols)

    for i in 1:rows
        for j in 1:cols
            if image[i, j]
                # Inside the shape, find the nearest edge (distance to a `false` pixel)
                min_dist = Inf
                for x in 1:rows
                    for y in 1:cols
                        if !image[x, y]
                            dist = metric((i, j), (x, y))
                            min_dist = min(min_dist, dist)
                        end
                    end
                end
                sdf_matrix[i, j] = min_dist
            else
                # Outside the shape, find the nearest edge (distance to a `true` pixel)
                min_dist = Inf
                for x in 1:rows
                    for y in 1:cols
                        if image[x, y]
                            dist = metric((i, j), (x, y))
                            min_dist = min(min_dist, dist)
                        end
                    end
                end
                sdf_matrix[i, j] = -min_dist
            end
        end
    end

    return sdf_matrix
end

# Default Euclidean distance metric
function euclidean(p1::Tuple{Int,Int}, p2::Tuple{Int,Int})::Float64
    return sqrt((p1[1] - p2[1])^2 + (p1[2] - p2[2])^2)
end