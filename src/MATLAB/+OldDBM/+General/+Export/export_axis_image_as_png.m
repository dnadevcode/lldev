function [] = export_axis_image_as_png(hAxis, pngOutputFilepath)
    try
        axisFrame = getframe(hAxis);
        axisImg = frame2im(axisFrame);
        imwrite(axisImg, pngOutputFilepath);
    catch
        warning('Failed to export image');
    end
end