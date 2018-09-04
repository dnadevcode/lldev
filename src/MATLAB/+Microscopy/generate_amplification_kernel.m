function [amplificationKernel] = generate_amplification_kernel(neighborhoodCutoffDistByDim, distWarpingPowers)
    % amplification kernel is an array meant for convolution for which
    %   convolving with the kernel on an array results in an array where
    %   the original value at an index has no influence on itself, but gets
    %   influenced by the other values that were in its local neighboring
    %   area, and the influence of a particular value in that area
    %   decreases monotonically as the euclidean distance to the
    %   value's location increases (until values are far enough away that
    %   they are effectively outside the neighboring area and have no
    %   influence at all)
    % the outputted convolution array has the following properties:
    %   it is 3 dimensional
    %   it is symmetrical in each of the 3-dimensions
    %   it has an odd length in each dimension
    %   it has the value at the center index of the entire array set to
    %    zero
    %   it has a value of zero where the index is not contained within an
    %    ellipsoid with the semi-principal axis lengths (euclidean
    %    distances from the center index) corresponding with the input
    %    provided as "neighborhoodCutoffDistByDim"
    %  "surfing" the values of the 2-dimensional (planar) arrays
    %   that intersect the center of the array produces a surface like a
    %   volcanos crust where the center and edges past a radius has a value
    %   of 0 and the other values are proportional to the reciprocal of the
    %   euclidean distance from the center (raised to some powers specified
    %   via "distWarpingPowers") and surfing other 2-dimensional arrays
    %   produces the same general shape but with a peak instead of a drop
    %   to zero at the center
    
    validateattributes(neighborhoodCutoffDistByDim, {'numeric'}, {'positive', 'integer', 'vector', 'numel', 3});
    validateattributes(distWarpingPowers, {'numeric'}, {'>=', 1, 'vector', 'numel', 3});

    dimDists = cell(3, 1);
    [dimDists{1}, dimDists{2}, dimDists{3}] = meshgrid(...
        -neighborhoodCutoffDistByDim(1):neighborhoodCutoffDistByDim(1),...
        -neighborhoodCutoffDistByDim(2):neighborhoodCutoffDistByDim(2),...
        -neighborhoodCutoffDistByDim(3):neighborhoodCutoffDistByDim(3));
    
    centerMask = (dimDists{1} == 0) & (dimDists{2} == 0) & (dimDists{3} == 0);
    ellipsoidNeighborhoodMask = (...
        ((dimDists{1}/neighborhoodCutoffDistByDim(1)).^2) +...
        ((dimDists{2}/neighborhoodCutoffDistByDim(2)).^2) +...
        ((dimDists{3}/neighborhoodCutoffDistByDim(3)).^2)) <= 1;
    relevantPeers = (ellipsoidNeighborhoodMask & ~centerMask);
    
    % warp distances in each dimension such that further distances are
    % treated as if they are exponentially further
    
    warpedDists = cell(3, 1);
    for dimNum=1:3
        warpedDists{dimNum} = double(dimDists{dimNum}).^(distWarpingPowers(dimNum));
        warpedDists{dimNum}(~relevantPeers) = inf;
    end
    
    warpedDist = sqrt(...
        warpedDists{1}.^2 +...
        warpedDists{2}.^2 +...
        warpedDists{3}.^2);
    
    % use the reciprocal of the warped distance as the weight in the
    %  convolution kernel 
    amplificationKernel = 1/warpedDist;
    
    % normalize such that the total sum of the convolution array is 1
    %  (or at least very close to it) 
    amplificationKernel = amplificationKernel./sum(amplificationKernel(:));
end