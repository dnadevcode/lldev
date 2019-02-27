function [ matchFilteredKymo ] = match_filter_kymo( kymo, sets )
    %MATCH_FILTER_KYMO Summary of this function goes here
    %   Detailed explanation goes here
        %
    matchFilteredKymo = zeros(size(kymo));

    for i=1:size(kymo,1)
        matchFilteredKymo(i,:) = imgaussfilt(kymo(i,:),sets.sigma);
    end

end

