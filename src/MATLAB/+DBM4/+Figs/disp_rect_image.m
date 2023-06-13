function [] = disp_rect_image(hAxis, imgArr, imgHeaderText)

    cutout = 0.01;
    num_to_cut = ceil( numel(imgArr) * cutout / 2);
    sorted_data = sort(imgArr(~isnan(imgArr)));
    cmin = sorted_data( num_to_cut );
    cmax = sorted_data( end - num_to_cut + 1);

    if cmin > cmax % in case wrong elts chosen for cutoffs
        ctemp = cmin;
        cmin = cmax;
        cmax = ctemp;
    end

    imagesc(imgArr, 'Parent', hAxis, [cmin cmax]);
    hold(hAxis, 'on');
    colormap(hAxis, gray());
    title(imgHeaderText,'FontSize',6);

    
    hAxis.YColor = [0 1 0];
    hAxis.XColor = [0 1 0];
    
    set(hAxis,'XTick',[]);
    set(hAxis,'YTick',[]);
    hold(hAxis, 'off');

end

