function [feature_colormap] = get_color_map(featuresCellArray,imgSize)

%     import dotkymoAlignment.*
    
%     [rowsCell,colsCell]=cellfun(@(linearIndxArray) arrayfun(@(linearIndx)ind2sub(imgSize,linearIndx),linearIndxArray),featuresCellArray,'uniformoutput',false);

%     if nargin < 3
%         numColors = length(featuresCellArray);
%     end

    feature_colormap = ones([imgSize 3]);
    
    import ThirdParty.DistinguishableColors.distinguishable_colors;
    RGBcolors = distinguishable_colors(length(featuresCellArray),'w');
    
    for feature = 1:length(featuresCellArray)
        
        for idx = 1:size(featuresCellArray{feature},1)
%             organizedFeatures{feature,1}(idx,:) = [rowsCell{feature}(idx) colsCell{feature}(idx)];
%             organizedFeatures{feature,2}(idx) = colsCell{feature}(idx);
                    
%             feature_map(rowsCell{feature}(idx),colsCell{feature}(idx)) = feature;
            feature_colormap(featuresCellArray{feature}(idx,1),featuresCellArray{feature}(idx,2),:) = RGBcolors(feature,:);
        end
    end
    
%     figure, imshow(feature_map);
%     figure, imagesc(feature_colormap);
    
end