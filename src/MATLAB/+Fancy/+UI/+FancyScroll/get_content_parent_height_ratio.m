function contentViewportRatio = get_content_parent_height_ratio(panelHandle)
    import Fancy.UI.FancyPositioning.get_pixel_height;
    contentViewportRatio = get_pixel_height(panelHandle)/get_pixel_height(panelHandle.Parent);
end