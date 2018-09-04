function [ xcorrs,coverage,fullCoverage ] = get_cc_fft( shortVec, longVec, shortVecBit, longVecBit )
    % get_cc_fft
    
    % input shortVec, longVec, shortVecBit, longVecBit 
    
    % output xcorrs
    
    
    shortVec = shortVec(:)';
    longVec = longVec(:)';
    if nargin < 3
        shortVecBit = true(size(shortVec));
    end
    if nargin < 4
        longVecBit = true(size(longVec));
    end
    shortVecBit = shortVecBit(:)';
    longVecBit = longVecBit(:)';
   
    shortVecCut = shortVec(logical(shortVecBit));
    shortLength = length(shortVecCut);
    longLength = length(longVec);
    
    movMean = conv([double(longVecBit),double(longVecBit(1:shortLength-1))],ones(1,shortLength));
    coverage = movMean(shortLength:longLength+shortLength-1);
    
    import CA.CombAuc.Core.Comparison.cc_fft;
    [xx1, xx2] = cc_fft(zscore(shortVecCut), longVec);

    xx2 = circshift(xx2,[0,length(shortVec)+1-find(shortVecBit,1,'first')]);
    xx1 = circshift(xx1,[0,1-find(shortVecBit,1,'first')]);
    xcorrs = [xx1;xx2];
    
    fullCoverage = coverage==length(shortVecCut);

   % coverageLens = coverageLens(:, colIndices);
end

