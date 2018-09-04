function [frameOutputs] = apply_per_frame(movieIn, fn)
    numFrames = size(movieIn, 4);
    sz = size(fn(movieIn(:, :, :, 1)));
    frameOutputs = NaN([sz, numFrames]);
    colons = repmat({':'}, [1, length(sz)]);
    for frameNum=1:numFrames
        frameOutputs(colons{:}, frameNum) = fn(movieIn(:, :, :, frameNum));
    end
end