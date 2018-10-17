function [ distanceArray, matchMetric ] = calculate_coupled_point_distances( dataSetA, dataSetB, coupledPointsInB )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

    numDataPairs = numel(coupledPointsInB);

    distanceArray = nan(numDataPairs,1);

    for coupledPointIdx = 1:numDataPairs
        distanceArray(coupledPointIdx) = dataSetB(coupledPointsInB(coupledPointIdx))-dataSetA(coupledPointIdx); 
    end
    
    matchMetric = sqrt(sum(distanceArray.^2));

end

