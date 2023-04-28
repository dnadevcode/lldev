function [] = disp_img_with_header(hAxis, imgArr, imgHeaderText)

    cutout = 0.01;
    num_to_cut = ceil( numel(imgArr) * cutout / 2);
    sorted_data = sort(imgArr(~isnan(imgArr)));
    cmin = sorted_data( num_to_cut );
    cmax = sorted_data( end - num_to_cut + 1);

    if cmin > cmax % in case wrong elts chosen for cutoffs
        ctemp =cmin;
        cmin = cmax;
        cmax =ctemp;
    end
    % imagesc(data, [cmin, cmax]);


    imagesc(imgArr, 'Parent', hAxis, [cmin cmax]);
    hold(hAxis, 'on');
    colormap(hAxis, gray());
    
    import OldDBM.General.UI.set_centered_header_text;
    set_centered_header_text(hAxis, imgHeaderText);
    hold(hAxis, 'off');
end