function [vectOut, stretchFactor] = apply_stretching(vectIn, approxStretchFactor)
    % APPLY_STRETCHING - interpolates the vector such that the output
    %   vector is of a length that is of the integer length closest to the 
    %   input vector's length multiplied by an approximate stretch factor
    % 
    % Inputs:
    %   vectIn
    %     input vector of real finite numbers to be interpolated
    %   approxStretchFactor
    %     the factor by which to stretch the vector's length to after
    %     rounding the output vector length to the nearest integer
    %     
    % Outputs:
    %   vectOut
    %     the output vector of length vectOutLen containing the
    %     interpolation of the input vector
    %   stretchFactor
    %     the actual ratio between the output vector's length and the input
    %     vector's length
    %
    % Authors:
    %   Saair Quaderi
    
    import CBT.Core.sample_interp_to_len;

    oldVectLen = length(vectIn);
    newVectLen = round(oldVectLen*approxStretchFactor);
    vectOut = sample_interp_to_len(vectIn, newVectLen);
    stretchFactor = newVectLen/oldVectLen;
end