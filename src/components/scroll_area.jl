mutable struct ScrollArea <: AbstractGuiComponent
    child::AbstractGuiComponent       # The scrollable child component
    vertical_scrollbar::ScrollBar  # Vertical scroll bar
    horizontal_scrollbar::ScrollBar  # Horizontal scroll bar
    content_width::Float32    # Width of the scrollable content
    content_height::Float32   # Height of the scrollable content
end

# Constructor for ScrollArea
function ScrollArea(child::AbstractGuiComponent; content_width=1.0, content_height=1.0)
    vertical_scrollbar = ScrollBar(child; width=10.0, axis=Vertical, handle_size=50.0)
    horizontal_scrollbar = ScrollBar(child; width=10.0, axis=Horizontal, handle_size=50.0)
    return ScrollArea(child, vertical_scrollbar, horizontal_scrollbar, content_width, content_height)
end

function apply_layout(scrollarea::ScrollArea)
    child = scrollarea.child
    vscroll = scrollarea.vertical_scrollbar
    hscroll = scrollarea.horizontal_scrollbar

    # Reset child dimensions to the full content size
    child.width = scrollarea.content_width
    child.height = scrollarea.content_height

    # Check if vertical scroll bar is needed
    if scrollarea.content_height > child.height
        vscroll.visible = true
        vscroll.x = child.x + child.width - vscroll.width
        vscroll.y = child.y
        vscroll.height = child.height
        child.width -= vscroll.width
    else
        vscroll.visible = false
    end

    # Check if horizontal scroll bar is needed
    if scrollarea.content_width > child.width
        hscroll.visible = true
        hscroll.x = child.x
        hscroll.y = child.y + child.height - hscroll.width
        hscroll.width = child.width
        child.height -= hscroll.width
    else
        hscroll.visible = false
    end
end

function render(scrollarea::ScrollArea)
    # Apply layout before rendering
    apply_layout(scrollarea)

    # Render the child component
    render(scrollarea.child)

    # Render the vertical scroll bar if visible
    if scrollarea.vertical_scrollbar.visible
        render(scrollarea.vertical_scrollbar)
    end

    # Render the horizontal scroll bar if visible
    if scrollarea.horizontal_scrollbar.visible
        render(scrollarea.horizontal_scrollbar)
    end
end

function handle_scroll_event(scrollbar::ScrollBar, scrollarea::ScrollArea, mouse_state::MouseState)
    if scrollbar.axis == Vertical
        # Vertical scrolling
        scrollarea.child.y = -scrollbar.scroll_position * (scrollarea.content_height - scrollarea.child.height)
    elseif scrollbar.axis == Horizontal
        # Horizontal scrolling
        scrollarea.child.x = -scrollbar.scroll_position * (scrollarea.content_width - scrollarea.child.width)
    end
end