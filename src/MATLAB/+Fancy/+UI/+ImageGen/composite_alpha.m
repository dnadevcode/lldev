function [ compositeRGB, compositeAlpha ] = composite_alpha(fgRGB, fgAlpha, bgRGB, bgAlpha)
    % COMPOSITE_ALPHA Composites images with red green and blue values 
    %  with transparency of a foreground
    %
    % Inputs:
    %   fgRGB
    %     (if double, 0-1, else 0-255)
    %     foreground image intensity matrix
    %          pixel-wise grayscale(MxNx1) or pixel-wise RGB (MxNx3)
    %   fgAlpha
    %     (if double, 0-1, else 0-255)
    %     foreground image transparency intensity matrix
    %          constant (1x1x1) or pixel-wise (MxNx1)
    %   bgRGB
    %     (if double, 0-1, else 0-255)
    %     background image intensity matrix
    %          pixel-wise grayscale(MxNx1) or pixel-wise RGB (MxNx3)
    %          constant grayscale (1x1x1) or  constant RGB (1x1x3)
    %   bgAlpha
    %     (if double, 0-1, else 0-255)
    %     background image transparency intensity matrix
    %          constant (1x1x1) or pixel-wise (MxNx1)
    %
    % Outputs:
    %   compositeRGB
    %     composite image intensity matrix (double from 0-1)
    %          pixel-wise RGB (MxNx3)
    %   compositeAlpha
    %     composite image transparency intensity matrix (double from 0-1)
    %          pixel-wise (MxNx1)
    %
    % Authors:
    %   Saair Quaderi
    
    import Fancy.UI.ImageGen.normalize_composite_alpha_inputs;
    
    if nargin < 2
        fgAlpha = [];
    end
    if nargin < 3
        bgRGB = [];
    end
    if nargin < 4
        bgAlpha = [];
    end
    
    szFgRGB = size(fgRGB);
    szBgRGB = size(bgRGB);
    if ((numel(szFgRGB) ~= 3) || (szFgRGB(3) ~= 3)...
            || not(isequal(szFgRGB, szBgRGB))...
            || not(isequal(szFgRGB(1:2), size(fgAlpha)))...
            || not(isequal(szBgRGB(1:2), size(bgAlpha)))...
            || feval(@(vals) any(isnan(vals)) | (min(vals) < 0) | (max(vals) > 1),...
                [fgRGB(:); fgAlpha(:); bgRGB(:); bgAlpha(:)]))
        [fgRGB, fgAlpha, bgRGB, bgAlpha] = normalize_composite_alpha_inputs(fgRGB, fgAlpha, bgRGB, bgAlpha);
    end

    
    fgAlphaRepMat = repmat(fgAlpha, [1 1 3]);
    bgAlphaRepMat = repmat(bgAlpha, [1 1 3]);
    compositeRGB = (fgAlphaRepMat.*fgRGB + (1 - fgAlphaRepMat).*bgAlphaRepMat.*bgRGB)./(fgAlphaRepMat + (1 - fgAlphaRepMat).*bgAlphaRepMat);
    compositeAlpha = 1 - (1 - fgAlpha).*(1 - bgAlpha);
    compositeRGB = round(compositeRGB.*255)./255;
    compositeAlpha = round(compositeAlpha.*255)./255;
end

