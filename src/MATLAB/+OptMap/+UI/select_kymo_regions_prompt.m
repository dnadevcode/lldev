function [kymo_crop_regions, selectionRegions] = select_kymo_regions_prompt(kymoImg, hParent)
    import Microscopy.UI.RegionSelection.select_image_region_prompt;
    
    if nargin < 3
        hFig = figure('Name', 'Select movie region');
        hParent = uipanel(hFig, 'Units', 'normal', 'Position', [0, 0, 1, 1]);
        createdUI = true;
    end
    hPanelMain = uipanel(hParent, 'Units', 'normal', 'Position', [0, 0.2, 1, 0.8]);
    
    selectionRegions = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
    idx = 1;
    done = false;
    selectionLabeling = zeros(size(kymoImg));
    dispImg = kymoImg;
    while not(done)
        [selectionRegion] = select_image_region_prompt(dispImg, hPanelMain);
        selectionRegions(uint32(idx)) = selectionRegion;
        selectionLabeling(selectionRegion.rowStartIdx:selectionRegion.rowEndIdx, selectionRegion.colStartIdx:selectionRegion.colEndIdx) = idx;
        done = true;
        idx = idx + 1;
    end
    if createdUI
        delete(hPanelMain);
        delete(hFig);
    end
    selectionRegions = values(mapObj, keys(selectionRegions));
    selectionRegions = selectionRegions(:);
    kymo_crop_regions = cellfun(@(selectionRegion) kymoImg(selectionRegion.rowStartIdx:selectionRegion.rowEndIdx, selectionRegion.colStartIdx:selectionRegion.colEndIdx), selectionRegions, 'UniformOutput', false);
end