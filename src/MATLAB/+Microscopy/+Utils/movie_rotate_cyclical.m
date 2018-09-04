function [rotMov, rotSegmentFrame] = movie_rotate_cyclical(mov, rotationAngle, rotationSamplingMethod)
    if nargin < 3
        rotationSamplingMethod = 'bilinear';
    end
    
    szMov = size(mov);
    
    tmpRotSegmentFrame = 2 + zeros(szMov(1:2));
    tmpRotSegmentFrame = [tmpRotSegmentFrame - 1, tmpRotSegmentFrame; tmpRotSegmentFrame, tmpRotSegmentFrame];
    
    
    rotMov = repmat(mov, [2 2]);
    for dimIdx = 1:2
        shiftAmt = floor(szMov(dimIdx)/2);
        rotMov = circshift(rotMov, shiftAmt, dimIdx);
        tmpRotSegmentFrame = circshift(tmpRotSegmentFrame, shiftAmt, dimIdx);
    end
    rotMov = imrotate(rotMov, rotationAngle, rotationSamplingMethod, 'crop');
    tmpRotSegmentFrame = imrotate(tmpRotSegmentFrame, rotationAngle, rotationSamplingMethod, 'crop');
    for dimIdx = 1:2
        shiftAmt = -floor(szMov(dimIdx)/2);
        rotMov = circshift(rotMov, shiftAmt, dimIdx);
        tmpRotSegmentFrame = circshift(tmpRotSegmentFrame, shiftAmt, dimIdx);
    end
    c = repmat({':'}, [1, ndims(rotMov)]);
    c{1} = 1:szMov(1);
    c{2} = 1:szMov(2);
    
    if nargout > 1
        rotMov = rotMov(c{:});
        tmpRotSegmentFrame = tmpRotSegmentFrame(c{:});
        tmpRotSegmentFrame(rem(tmpRotSegmentFrame, 1) ~= 0) = 0;
        rotSegmentFrame = zeros(size(tmpRotSegmentFrame));
        mask = (tmpRotSegmentFrame == 1);
        rotSegmentFrame(mask) = 1;
        tmpRotSegmentFrame(mask) = 0;
        mask = (tmpRotSegmentFrame > 0);
        tmpRotSegmentFrame = labelmatrix(bwconncomp(mask));
        rotSegmentFrame(mask) = tmpRotSegmentFrame(mask) + 1;
    end
end