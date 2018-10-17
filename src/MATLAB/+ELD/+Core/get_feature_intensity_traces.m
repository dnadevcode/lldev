function [ featureIntensityTraces ] = get_feature_intensity_traces( kymoImgs, featuresCellArrays , featureWidth)

    if nargin < 3 || isempty(featureWidth)
        featureWidth = 7;
    end

    numKymos = length(kymoImgs);

    featureIntensityTraces = cell(numKymos,1);
    
    for kymo = 1:numKymos
        for feature = 1:length(featuresCellArrays{kymo})
            featureImg = zeros(size(kymoImgs{kymo}));
            for row = 1:size(featuresCellArrays{kymo}{feature},1)
                featureImg(featuresCellArrays{kymo}{feature}(row,1),featuresCellArrays{kymo}{feature}(row,2)) = 1;
            end
            featureImg = imdilate(featureImg,ones(1,featureWidth));
            featureImg = kymoImgs{kymo}.*featureImg;
            
            featureImg(featureImg == 0) = NaN;
            featureIntensityTraces{kymo}{feature} = nanmean(featureImg,2);
            
            figure, plot(featureIntensityTraces{kymo}{feature});
        end
    end
end

