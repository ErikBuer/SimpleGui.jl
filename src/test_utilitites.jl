using FileIO, ImageCore

function create_offscreen_framebuffer(width::Int, height::Int)
    # Generate a framebuffer
    framebuffer = Ref{UInt32}(0)
    ModernGL.glGenFramebuffers(1, framebuffer)
    ModernGL.glBindFramebuffer(ModernGL.GL_FRAMEBUFFER, framebuffer[])

    # Create a texture to render to
    texture = Ref{UInt32}(0)
    ModernGL.glGenTextures(1, texture)
    ModernGL.glBindTexture(ModernGL.GL_TEXTURE_2D, texture[])
    ModernGL.glTexImage2D(ModernGL.GL_TEXTURE_2D, 0, ModernGL.GL_RGB, width, height, 0, ModernGL.GL_RGB, ModernGL.GL_UNSIGNED_BYTE, C_NULL)
    ModernGL.glTexParameteri(ModernGL.GL_TEXTURE_2D, ModernGL.GL_TEXTURE_MIN_FILTER, ModernGL.GL_LINEAR)
    ModernGL.glTexParameteri(ModernGL.GL_TEXTURE_2D, ModernGL.GL_TEXTURE_MAG_FILTER, ModernGL.GL_LINEAR)

    # Attach the texture to the framebuffer
    ModernGL.glFramebufferTexture2D(ModernGL.GL_FRAMEBUFFER, ModernGL.GL_COLOR_ATTACHMENT0, ModernGL.GL_TEXTURE_2D, texture[], 0)

    # Check if the framebuffer is complete
    if ModernGL.glCheckFramebufferStatus(ModernGL.GL_FRAMEBUFFER) != ModernGL.GL_FRAMEBUFFER_COMPLETE
        error("Framebuffer is not complete!")
    end

    return framebuffer[], texture[]
end

function save_screenshot_offscreen(output_file::String, width::Int, height::Int)
    # Create an offscreen framebuffer
    framebuffer, texture = create_offscreen_framebuffer(width, height)

    # Bind the framebuffer
    ModernGL.glBindFramebuffer(ModernGL.GL_FRAMEBUFFER, framebuffer)

    # Set the viewport to match the framebuffer size
    ModernGL.glViewport(0, 0, width, height)

    # Update the projection matrix to match the framebuffer size
    global projection_matrix
    projection_matrix = SimpleGui.get_orthographic_matrix(0.0f0, Float32(width), Float32(height), 0.0f0, -1.0f0, 1.0f0)

    # Clear the framebuffer
    ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

    # Render the scene
    render(main_container)

    # Read the pixels from the framebuffer
    buffer = Array{UInt8}(undef, 3, width, height)  # RGB format
    ModernGL.glReadPixels(0, 0, width, height, ModernGL.GL_RGB, ModernGL.GL_UNSIGNED_BYTE, buffer)

    # Flip the image vertically (OpenGL's origin is bottom-left)
    flipped_buffer = reverse(buffer, dims=3)

    # Save the image as a PNG
    img = permutedims(flipped_buffer, (3, 2, 1))  # Convert to (width, height, channels)
    save(output_file, img)

    # Clean up
    ModernGL.glDeleteFramebuffers(1, Ref(framebuffer))
    ModernGL.glDeleteTextures(1, Ref(texture))
end