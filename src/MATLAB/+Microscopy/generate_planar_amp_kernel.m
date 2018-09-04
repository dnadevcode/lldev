function ampKernel = generate_planar_amp_kernel(maxDist)
    distRelevanceDropoffPower = 2;
    d = (floor(-maxDist):1:ceil(maxDist));
    [dx, dy] = meshgrid(d, d);
    ampKernel = (dx.^2 + dy.^2).^((1/2) * (-1/distRelevanceDropoffPower));
    ampKernel((ampKernel == Inf) | (ampKernel < maxDist.^(-1/distRelevanceDropoffPower))) = NaN;
    ampKernel = ampKernel./nansum(ampKernel(:));
    ampKernel(isnan(ampKernel)) = 0;
end