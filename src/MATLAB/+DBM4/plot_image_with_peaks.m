function [f] = plot_image_with_peaks(image,peaksToPlot,visible)
    
    if nargin < 3
        f = figure; % make invisible figure
    else
        f = figure('Visible', 'off'); % make invisible figure
    end
    
    cutout = 0.01;
    num_to_cut = ceil( numel(image) * cutout / 2);
    sorted_data = sort(image(image~=0));
    cmin = sorted_data( num_to_cut );
    cmax = sorted_data( end - num_to_cut + 1);
    % imagesc(data, [cmin, cmax]);

    
    imagesc(image, [cmin cmax]);
%     hold(hAxis, 'on');
    colormap(gray);
    hold on
    for idd = 1:length(peaksToPlot)
        plot(repmat(peaksToPlot(idd),1,size(image,1)),1:size(image,1),'red')
    end
end

