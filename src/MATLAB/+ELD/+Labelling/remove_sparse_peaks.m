function [ peakMap ] = remove_sparse_peaks( peakMap, sets )
    % REMOVE_SPARSE_PEAKS 
    % Input peakMap, sets
    % Output peakMap
    
    % Dilation structural element
	sel=zeros(3,2*sets.localFluctuationWindow+1);
    sel(1,:) = 1;
    sel(3,:) = 1;
    % Dilate
    tmp_1= imdilate(peakMap,sel); 
    % update the feature map
    peakMap = peakMap.*tmp_1;


end

