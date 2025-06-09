using FileIO, ImageCore

function create_offscreen_framebuffer(width::Int, height::Int)
    framebuffer = Ref{UInt32}(0)
    ModernGL.glGenFramebuffers(1, framebuffer)
    ModernGL.glBindFramebuffer(ModernGL.GL_FRAMEBUFFER, framebuffer[])

    texture = Ref{UInt32}(0)
    ModernGL.glGenTextures(1, texture)
    ModernGL.glBindTexture(ModernGL.GL_TEXTURE_2D, texture[])
    ModernGL.glTexImage2D(ModernGL.GL_TEXTURE_2D, 0, ModernGL.GL_RGB, width, height, 0, ModernGL.GL_RGB, ModernGL.GL_UNSIGNED_BYTE, C_NULL)
    ModernGL.glTexParameteri(ModernGL.GL_TEXTURE_2D, ModernGL.GL_TEXTURE_MIN_FILTER, ModernGL.GL_LINEAR)
    ModernGL.glTexParameteri(ModernGL.GL_TEXTURE_2D, ModernGL.GL_TEXTURE_MAG_FILTER, ModernGL.GL_LINEAR)

    ModernGL.glFramebufferTexture2D(ModernGL.GL_FRAMEBUFFER, ModernGL.GL_COLOR_ATTACHMENT0, ModernGL.GL_TEXTURE_2D, texture[], 0)

    if ModernGL.glCheckFramebufferStatus(ModernGL.GL_FRAMEBUFFER) != ModernGL.GL_FRAMEBUFFER_COMPLETE
        error("Framebuffer is not complete!")
    end

    return framebuffer[], texture[]
end

function save_screenshot_offscreen(ui_funciton::Function, output_file::String, width::Int, height::Int)

    # Initialize GLFW window (offscreen context)
    gl_window = GLFW.Window(name="Offscreen", resolution=(width, height))
    GLA.set_context!(gl_window)
    GLFW.MakeContextCurrent(gl_window)


    ModernGL.glEnable(ModernGL.GL_BLEND)
    ModernGL.glBlendFunc(ModernGL.GL_SRC_ALPHA, ModernGL.GL_ONE_MINUS_SRC_ALPHA)

    initialize_shaders()

    root_view::AbstractView = ui_funciton()

    framebuffer, texture = create_offscreen_framebuffer(width, height)
    ModernGL.glBindFramebuffer(ModernGL.GL_FRAMEBUFFER, framebuffer)
    ModernGL.glViewport(0, 0, width, height)
    ModernGL.glClear(ModernGL.GL_COLOR_BUFFER_BIT)

    projection_matrix = get_orthographic_matrix(0.0f0, Float32(width), Float32(height), 0.0f0, -1.0f0, 1.0f0)

    interpret_view(root_view, 0.0f0, 0.0f0, Float32(width), Float32(height), projection_matrix)

    buffer = Array{UInt8}(undef, 3, width, height)  # RGB format
    ModernGL.glReadPixels(0, 0, width, height, ModernGL.GL_RGB, ModernGL.GL_UNSIGNED_BYTE, buffer)

    flipped_buffer = reverse(buffer, dims=3)

    img = permutedims(flipped_buffer, (3, 2, 1))  # Convert to (width, height, channels)
    save(output_file, img)

    ModernGL.glDeleteFramebuffers(1, Ref(framebuffer))
    ModernGL.glDeleteTextures(1, Ref(texture))
    GLFW.DestroyWindow(gl_window)
end