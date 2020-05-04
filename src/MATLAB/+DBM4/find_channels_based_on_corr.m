function [corrs] = find_channels_based_on_corr(image,dist)
    % find_channels_based_on_corr
    %
    %   Args:
    %       image,dist
    %   
    %   Returns:
    %
    %       corrs
    
%     % each peak in correlation corrs corresponds to a peak in columnMeans.
    % these peaks can be shifted a little bit, since we don't exactly hit
    % the peak with the mean (it might be to the left or to the right of
    % the detected peak position), and corrs finds the correlation between 
    % i'th and i+1 column, so for the pixel for continued classification,
    % we need to use max (or mean) between i and i+1 intensities in A. This
    % can be written as
    numPoints = size(image,2)-dist;
    corrs = zeros(1,numPoints);
%     corrs2 = zeros(1,numPoints);

    for i=1:numPoints
        
        bar1 = image(:,i);
        bar2 = image(:,i+dist);

        % compute correlations
        % should only across nonzero entriess
        mask1 = logical((bar1~=0).*(bar2~=0));
        corrs(i) = zscore(bar1(mask1)')*zscore(bar2(mask1))/length(bar1(mask1));
        
%         bar3 = image(:,i+2);
%         mask2 = logical((bar1~=0).*(bar3~=0));
%         corrs2(i) = zscore(bar1(mask2)')*zscore(bar3(mask2))/length(bar1(mask2));

    end
end

