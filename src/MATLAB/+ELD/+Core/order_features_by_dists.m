function [ ordered_dists, ordering ] = order_features_by_dists(unordered_dists)

    numDists = length(unordered_dists);

    pos = zeros(numDists+1,1);
    pos(1) = 0;
    for feature = 2:numDists+1
        pos(feature) = pos(feature-1) + unordered_dists(feature-1);
    end
    
    [sortedPos,ordering] = sort(pos);
    
    ordered_dists = diff(sortedPos); 

end

