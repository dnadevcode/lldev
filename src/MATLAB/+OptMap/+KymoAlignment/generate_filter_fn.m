function filterFn = generate_filter_fn(filterType, filterSize, gaussianKernelSigma, useEdgeExtension )
    %GENERATE_FILTER_FN - Higher-order function that generates an image 
    %  filtering function of type "gaussian" or "log" (laplacian of
    %  gaussian)
    % 
    %
    % Inputs:
    %   filterType
    %     'gaussian' or 'log'
    %   filterSize
    %     the size of the filter window
    %	gaussianKernelSigma
    %     "sigma" (standard deviation) width of gaussian kernel
    %   useEdgeExtension (optional)
    %     if true, pads the image by extending image edge values prior
    %      to convolution (and then extracting from the padded result)
    %     defaults to true
    % 
    % Outputs:
    %   filterFn
    %     a function which takes in an input image and outputs a filtered
    %     image
    %
    % Authors:
    %  Saair Quaderi

    if nargin < 4
        useEdgeExtension = true;
    end
    function filteredImg = filter_fn(inputImg)
        % LOG_FILTER - gets the filtering function for an image
        %
        % Inputs:
        %   inputImg
        %     the image
        %
        % Outputs:
        %   filteredImg
        %     the filtered image
        %
        % Authors:
        %  Saair Quaderi (2015-11)
        %   based off of code by Charleston Noble but with
        %    corrected off-by-one error for extraction of convolved image
        %    area and a number of API/cosmetic code changes

        % Pad (if necessary)
        paddedImg = inputImg;
        if useEdgeExtension
            padding = ceil(filterSize(1:2)./2);
            paddedImg = padarray(paddedImg, padding, 'replicate');
        end

        % Generate filter to convolve image with
        filter = fspecial(filterType, filterSize, gaussianKernelSigma);

        % Apply Laplacian of Gaussian filter
        filteredImg = conv2(paddedImg, filter, 'same');

        % Unpad (if necessary)
        if useEdgeExtension
            nonpaddingRows = (1:size(inputImg, 1)) + padding(1);
            nonpaddingCols = (1:size(inputImg, 2)) + padding(2);
            filteredImg = filteredImg(nonpaddingRows, nonpaddingCols);
        end
    end
    filterFn = @filter_fn;
end

