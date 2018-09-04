function [vectOut] = sample_interp_to_len(vectIn, vectOutLen, interpMethod)
    % SAMPLE_INTERP_TO_LEN - interpolates the vector such that the output
    %   vector is of a specified length and has the same first and last
    %   data points
    %
    % Inputs:
    %   vectIn
    %     input vector of real finite numbers to be interpolated
    %   vectOutLen
    %     the length of the output vector (must be > 1)
    %   interpMethod (optional, defaults to 'linear')
    %     the interpolation method for interp1
    %     the available methods are:
    %  
    %        'linear'   - (default) linear interpolation
    %        'nearest'  - nearest neighbor interpolation
    %        'next'     - next neighbor interpolation
    %        'previous' - previous neighbor interpolation
    %        'spline'   - piecewise cubic spline interpolation (SPLINE)
    %        'pchip'    - shape-preserving piecewise cubic interpolation
    %        'cubic'    - same as 'pchip'
    %        'v5cubic'  - the cubic interpolation from MATLAB 5, which does not
    %                     extrapolate and uses 'spline' if X is not equally
    %                     spaced.
    % 
    % Outputs:
    %   vectOut
    %     the output vector of length vectOutLen containing the
    %     interpolation of the input vector
    %
    % Authors:
    %   Saair Quaderi
    
    validateattributes(vectIn, {'numeric'}, {'vector', 'real', 'finite'}, 1);
    vectInLen = length(vectIn);
    if vectInLen < 2
        error('Input vector must contain at least two datapoints');
    end
    validateattributes(vectOutLen, {'numeric'}, {'scalar', 'integer', '>', 1}, 2);
    if nargin < 3
        interpMethod = 'linear';
    end
    if vectOutLen == vectInLen
        vectOut = vectIn;
    else
        vectOut = interp1(vectIn, linspace(1, vectInLen, vectOutLen), interpMethod);
    end
end