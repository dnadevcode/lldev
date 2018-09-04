function [yxCoords] = find_lap_mapping(costMat)
    import ThirdParty.Murty.Murty;
    [~, item2Customer, ~, ~] = Murty(costMat, 1); %cols in costMat (associated with reference barcode indices) represent items
    warpedIdxs = item2Customer(:);
    warpedIdxs(warpedIdxs == 0) = NaN;
    alignedIdxs = (1:length(warpedIdxs))';
    yxCoords = [warpedIdxs, alignedIdxs];
    
    nanCoords = isnan(warpedIdxs);
    yxCoords = yxCoords(not(nanCoords), :);
end