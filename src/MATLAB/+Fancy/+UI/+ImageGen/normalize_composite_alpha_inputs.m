function [ fgRGB, fgAlpha, bgRGB, bgAlpha ] = normalize_composite_alpha_inputs(fgRGB, fgAlpha, bgRGB, bgAlpha)
    % NORMALIZE_COMPOSITE_ALPHA_INPUTS - normalizes the RGB and alpha
    %   foreground and background image channels and throws errors if they 
    %   cannot be normalized to a consistent size
    % 
    % Inputs:
    %   fgRGB
    %     the image foreground colors as an MxNx1 grayscale or an MxNx3
    %     RGB image
    %     values must be doubles from 0-1 or alternatively
    %     integers from 0-255
    %   fgAlpha
    %     the empty, scalar, or MxN alpha channel for the foreground image
    %     if empty, it is treated like the scalar value 1
    %     if scalar, it is treated like an MxN matrix with the scalar value
    %       repeated
    %     values must be doubles from 0-1 or alternatively
    %     integers from 0-255
    %   bgRGB
    %     the empty, scalar, or MxNx1 grayscale or MxNx3 RGB image for the
    %       background image
    %     if empty, it is treated like the scalar value 1
    %     if scalar, it is treated like an MxNx3 matrix with the scalar
    %       value repeated
    %     values must be doubles from 0-1 or alternatively
    %     integers from 0-255
    %   bgAlpha
    %     the empty, scalar, or MxN alpha channel for the foreground image
    %     if empty, it is treated like the scalar value 1
    %     if scalar, it is treated like an MxN matrix with the scalar value
    %       repeated
    %     values must be doubles from 0-1 or alternatively
    %     integers from 0-255
    %
    % Outputs:
    %   fgRGB
    %     MxNx3 RGB foreground image
    %   fgAlpha
    %     MxNx1 foreground alpha channel
    %   bgRGB
    %     MxNx3 RGB background image
    %   bgAlpha
    %     MxNx1 background alpha channel
    %
    % Authors:
    %   Saair Quaderi
    
    if (size(fgRGB, 3) == 1)
        fgRGB = repmat(fgRGB, [1 1 3]);
    end
    if not(isa(fgRGB, 'double'))
        validateattributes(fgRGB, {'numeric'}, {'integer', 'nonnegative', '<=', 255});
        fgRGB = double(fgRGB)/255;
    else
        validateattributes(fgRGB, {'numeric'}, {'nonnegative', '<=', 1});
    end
    
    necessaryFgAlphaSize = size(fgRGB);
    necessaryFgAlphaSize(3) = 1;
    if isempty(fgAlpha)
        fgAlpha = 1;
    end
    if not(isa(fgAlpha, 'double'))
        validateattributes(fgRGB, {'numeric'}, {'integer', 'nonnegative', '<=', 255});
        fgAlpha = double(fgAlpha)/255;
    else
        validateattributes(fgRGB, {'numeric'}, {'nonnegative', '<=', 1});
    end
    if isscalar(fgAlpha)
        fgAlpha = repmat(fgAlpha, necessaryFgAlphaSize);
    end
    
    necessaryBgSize = size(fgRGB);
    if isempty(bgRGB)
        bgRGB = 1;
    end
    if not(isa(bgRGB, 'double'))
        validateattributes(bgRGB, {'numeric'}, {'integer', 'nonnegative', '<=', 255});
        bgRGB = double(bgRGB)/255;
    else
        validateattributes(fgRGB, {'numeric'}, {'nonnegative', '<=', 1});
    end
    if isequal([size(bgRGB, 1), size(bgRGB, 2)], [1, 1])
        bgRGB = repmat(bgRGB, [necessaryBgSize(1:2), 1]);
    end
    if (size(bgRGB, 3) == 1)
        bgRGB = repmat(bgRGB, [1 1 3]);
    end
    
    
    necessaryBgAlphaSize = size(bgRGB);
    necessaryBgAlphaSize(3) = 1;
    if isempty(bgAlpha)
        bgAlpha = 1;
    end
    if not(isa(bgAlpha, 'double'))
        validateattributes(bgAlpha, {'numeric'}, {'integer', 'nonnegative', '<=', 255});
        bgAlpha = double(bgAlpha)/255;
    else
        validateattributes(bgAlpha, {'numeric'}, {'nonnegative', '<=', 1});
    end
    if isscalar(bgAlpha)
        bgAlpha = repmat(bgAlpha, necessaryBgAlphaSize);
    end
    
    szFgRGB = size(fgRGB);
    szBgRGB = size(bgRGB);
    
    szFgAlpha = [size(fgAlpha), 1];
    szFgAlpha = szFgAlpha(1:3);
    
    szBgAlpha = [size(bgAlpha), 1];
    szBgAlpha = szBgAlpha(1:3);
    
    if not(isequal(szFgRGB, szBgRGB))
        error('Image size mismatch between foreground and background channels');
    end
    if not(isequal(szFgAlpha, [szFgRGB(1:2), 1]))
        error('Image size mismatch between foreground channels');
    end
    if not(isequal(szBgAlpha, [szBgRGB(1:2), 1]))
        error('Image size mismatch between background channels');
    end
end

