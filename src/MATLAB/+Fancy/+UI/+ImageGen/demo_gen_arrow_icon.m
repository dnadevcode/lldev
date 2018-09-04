function [icon] = demo_gen_arrow_icon(squareIconLen, fgColor, bgColor)
    % DEMO_GEN_ARROW_ICON - generates a square icon of a specified size
    %   of a right-pointing triangle "arrow"
    %   (might be useful for uicontrol 'CData' icons )
    %
    % Inputs:
    %  squareIconLen
    %   the length of the sides of the square icon to be generated
    %
    %  fgColor
    %    the color of the icon's foreground as a vector of three values
    %     in the range [0, 1]
    %
    %  bgColor
    %    the color of the icon's background as a vector of three values
    %     in the range [0, 1]
    %
    % Outputs:
    %   icon
    %     the square icon as a squareIconLen x squareIconLen x 3 matrix
    %      containing RGB image values in the range [0, 1]
    %
    % Authors:
    %   Saair Quaderi
    
    validateattributes(squareIconLen, {'numeric'}, {'finite', 'scalar', 'integer', '>', 0}, 1);
    validateattributes(fgColor, {'numeric'}, {'vector', 'numel', 3, '>=', 0, '<=', 1}, 2)
    validateattributes(bgColor, {'numeric'}, {'vector', 'numel', 3, '>=', 0, '<=', 1}, 3)
    
    arrowDiagLen = floor(sqrt(floor(((squareIconLen - ceil(squareIconLen/8))^2)/2))) - 1;
    icon = zeros(squareIconLen,squareIconLen);
    diamond = imrotate(ones(arrowDiagLen, arrowDiagLen), 45);
    arrowHeight = size(diamond, 1);
    arrowWidth = size(diamond, 2);
    arrowVertOffset = floor((squareIconLen - arrowHeight)/2);
    arrowHorizOffset = floor((squareIconLen - arrowWidth)/2);
    arrowRows = arrowVertOffset + (1:arrowHeight);
    arrowCols = arrowHorizOffset + (1:arrowWidth);
    icon(arrowRows, arrowCols) = diamond(:,:);
    icon = icon | flipud(icon);
    icon(:, 1:(squareIconLen/2)) = 0;
    icon = repmat(circshift(icon, -floor(.2*squareIconLen), 2), [1 1 3]);
    repTmp = [size(icon, 1), size(icon, 2), 1];
    permTmp = [3 2 1];
    icon = icon.*repmat(permute(fgColor(:), permTmp), repTmp) +...
        (1 - icon).*repmat(permute(bgColor(:), permTmp), repTmp);
end