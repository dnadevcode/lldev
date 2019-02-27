function ampKernel = generate_planar_amp_kernel(maxDist)
    % generate_planar_amp_kernel
    
    % :param maxDist: amplification parameter
    %
    % :returns: ampKernel
    
    % rewritten by Albertas Dvirnas
    
    % this amplification kernel takes the x^2+y^2 as the values, so 
    % the points maxDist away are more values than the points closer, 
    % and the value of the point itself is ignored
    
    % distRelevanceDropoffPower = 2;
    
    % values based on the maxDist (integer)
    d = (floor(-maxDist):1:ceil(maxDist));
    
    % Cartesian coordinates
    [dx, dy] = meshgrid(d, d);
    
    % amplification kernel
    ampKernel = (dx.^2 + dy.^2);%.^((1/2) * (-1/distRelevanceDropoffPower));
    
    % the point itself does not contribute
    ampKernel(ampKernel==0) = NaN;

    %  ampKernel((ampKernel == Inf) | (ampKernel < maxDist.^(-1/distRelevanceDropoffPower))) = NaN;
  
    ampKernel = ampKernel./nansum(ampKernel(:));
    
    % assign 0 back to the point
    ampKernel(isnan(ampKernel)) = 0;
    
end