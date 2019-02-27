function [ tS ] = generate_feature_time_series( kymo, features,sets )
    % generates time series for a given feature

    tS = cell(1,length(features));
    for i = 1:length(features)
        % this only takes the main pixel, take an average of intensities
        % perhaps?
        
        tS{i} = zeros(1,length(features{i}));
        for j=1:length(features{i})
            tS{i}(j) = kymo(features{i}(j,1),features{i}(j,2));
        end
  
    end

end

