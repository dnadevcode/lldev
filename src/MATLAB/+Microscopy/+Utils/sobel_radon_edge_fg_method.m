function [gradmag] = sobel_radon_edge_fg_method(I)
    % sobel_radon_edge_fg_method
	
    % :param I: input movie
    %
    % :returns: gradmag
    % Example: https://stackoverflow.com/questions/40984804/image-segmentation-matlab

    for dimIdx = 3:ndims(I)
        I = mean(I, dimIdx);
    end
    hy = fspecial('sobel');
    hx = hy';
    Iy = imfilter(double(I), hy, 'replicate');
    Ix = imfilter(double(I), hx, 'replicate');
    gradmag = sqrt(Ix.^2 + Iy.^2);
end