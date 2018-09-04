function dispImg = import_an_image()
    imgTypes = { ...
        'Bayer DNG'; ...
        'BGGR Bayer Tiff'; ...
        'GRBG Bayer Tiff'; ...
        'RGGB Bayer Tiff'; ...
        'GBRG Bayer Tiff'; ...
        'Grayscale Tiff'; ...
        'Color Tiff' ...
    };
    [~, idx] = Fancy.UI.FancyInput.dropdown_dialog('Image Type Selection', 'Choose tiff type', imgTypes);
    imgType = imgTypes{idx};
    if strcmp(imgType, 'Bayer DNG')
        import Microscopy.Import.import_dng;
        [dispImg, ~, ~, ~, bayerPattern] = import_dng([]);
        return;
    end
    if (sum(strfind(imgType, ' Bayer') == 5) == 1)
        bayerPattern = lower(imgType(1:4));
        imgType = imgType(6:end);
        switch imgType
            case 'Bayer Tiff'
                import Microscopy.Import.import_rgb_tiff_img;
                dispImg = import_rgb_tiff_img([], bayerPattern);
        end
        return;
    end
    switch imgType
        case 'Grayscale Tiff'
            import Microscopy.Import.import_grayscale_tiff_img;
            dispImg = import_grayscale_tiff_img();
        case 'Color Tiff'
            import Microscopy.Import.import_color_tiff_img;
            dispImg = import_color_tiff_img();
        otherwise
            dispImg = [];
    end
end