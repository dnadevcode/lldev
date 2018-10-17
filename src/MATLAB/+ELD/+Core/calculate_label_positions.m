function [ feature_positions, feature_position_variances ] = calculate_label_positions( feature_distances, feature_distance_variances )

    numFeatures = length(feature_distances)+1;

    feature_positions = zeros(numFeatures,1);
    feature_position_variances = zeros(numFeatures,1);
%     feature_positions(1) = 0;
%     feature_positions(end) = feature_distances(end);
     
    feature_position_variances(1) = feature_distance_variances(1)/2;
    feature_position_variances(end) = feature_distance_variances(end)/2;
    
    for feature = 2:numFeatures-1
        feature_positions(feature) = feature_positions(feature-1) + feature_distances(feature-1);
        feature_position_variances(feature) = (feature_distance_variances(feature-1) + feature_distance_variances(feature)) / 4;
    end
    
    feature_positions(numFeatures) = feature_positions(numFeatures-1) + feature_distances(numFeatures-1);

end

