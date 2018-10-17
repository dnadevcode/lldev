function [ feature_map , feature_colormap, organizedFeatures] = organize_features(featuresCellArray,imgSize)

    import dotkymoAlignment.*
    [rowsCell,colsCell]=cellfun(@(linearIndxArray) arrayfun(@(linearIndx)ind2sub(imgSize,linearIndx),linearIndxArray),featuresCellArray,'uniformoutput',false);

%     for feature = 1:length(rowsCell)
%         colIndStart(feature) = colsCell{feature}(1);
%         colInd2(feature) = colsCell{feature}(2);
%         colIndEnd(feature) = colsCell{feature}(end);
%         rowIndStart(feature) = rowsCell{feature}(1);
%         rowIndEnd(feature) = rowsCell{feature}(end);
%     end
    
    meanPositions = cellfun(@mean,colsCell,'uniformoutput',false);
    [~,ordering] = sort(cell2mat(meanPositions));
    rowsCell = rowsCell(ordering);
    colsCell = colsCell(ordering);
    
    organizedFeatures = cell(length(rowsCell),1);
    feature_map = zeros(imgSize);
    feature_colormap = ones([imgSize 3]);
    
    import ThirdParty.DistinguishableColors.distinguishable_colors;
    RGBcolors = distinguishable_colors(length(featuresCellArray),'w');
    
    for feature = 1:length(rowsCell)
        
        for idx = 1:length(rowsCell{feature})
            organizedFeatures{feature,1}(idx,:) = [rowsCell{feature}(idx) colsCell{feature}(idx)];
%             organizedFeatures{feature,2}(idx) = colsCell{feature}(idx);
                    
            feature_map(rowsCell{feature}(idx),colsCell{feature}(idx)) = feature;
            feature_colormap(rowsCell{feature}(idx),colsCell{feature}(idx),:) = RGBcolors(feature,:);
        end
    end
    
%     figure, imshow(feature_map);
%     figure, imshow(feature_colormap);
    
end

