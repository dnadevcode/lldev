function [croppedMovie, croppingDetails] = select_movie_region_prompt(inputMovie, dispImg, hPanel)
    
    if nargin < 2
        dispImg = mean(inputMovie, 4);
    end
    if nargin < 3
        hFig = figure('Name', 'Select movie region');
        hPanel = uipanel(hFig, 'Units', 'normal', 'Position', [0, 0, 1, 1]);
        createdUI = true;
    end
    
    import Microscopy.UI.RegionSelection.select_image_region_prompt;
    [croppingDetails] = select_image_region_prompt(dispImg, hPanel);
    if createdUI
        delete(hPanel);
        delete(hFig);
    end
    
    croppingDetails.frameStartIdx = 1;
    croppingDetails.frameEndIdx = size(inputMovie, 4);
    
    croppedFrameIdxs = croppingDetails.frameStartIdx:croppingDetails.frameEndIdx;
    croppedRowIdxs = croppingDetails.rowStartIdx:croppingDetails.rowEndIdx;
    croppedColIdxs = croppingDetails.colStartIdx:croppingDetails.colEndIdx;
    croppedMovie = inputMovie(croppedRowIdxs, croppedColIdxs, :, croppedFrameIdxs);
end