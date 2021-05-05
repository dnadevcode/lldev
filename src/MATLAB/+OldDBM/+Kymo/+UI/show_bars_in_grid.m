function [] = show_bars_in_grid(hPanel, kymoImgs, kymoHeaders)
    % SHOW_BARS_IN_GRID - displays the barcodes
    %  in a grid in the panel
    %
    % Inputs:
    %   hPanel
    %     handle to panel in which to display the kymographs
    %   kymoImgs
    %     cell vector of kymograph images
    %   kymoHeaders
    %     cell vector of kymograph header texts
    %
    % Authors:
    %   Saair Quaderi
    

    numKymos = length(kymoImgs);

    numNewAxisHandles = numKymos;

    import Fancy.UI.FancyPositioning.FancyGrid.generate_axes_grid;
%     import OldDBM.General.UI.disp_img_with_header;
    hNewAxes = generate_axes_grid(hPanel, numNewAxisHandles);

    for kymoNum = 1:numKymos
        hAxis = hNewAxes(kymoNum);
        kymoImg = kymoImgs{kymoNum};
        kymoHeader = kymoHeaders{kymoNum};
 
        plot(kymoImg, 'Parent', hAxis)
        
        hold(hAxis, 'on');

        import OldDBM.General.UI.set_centered_header_text;
        set_centered_header_text(hAxis, kymoHeader,'black');
        hold(hAxis, 'off');
    end
end