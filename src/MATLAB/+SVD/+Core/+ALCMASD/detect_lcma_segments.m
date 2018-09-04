function lcmaSegments = detect_lcma_segments(seq, thresholdParam, lengthParam)
    %Computes the LCMA segments of a sequence. 
    %Input: a sequence of values, the LCMA threshold parameter and
    %the LCMA length parameter.
    %Output: an array lcmaArray that is a two-column matrix where each row stores the
    %start and end indices for the LCMA segments in 'sequence'.
    %'sequence' should be an array of step-cost values.
    seqLen = length(seq);
    arrIdx = 0;
    lcmaSegments = NaN(seqLen - lengthParam, 2);
    for subseqStartIdx = 1:(seqLen - lengthParam)
        subseqEndIdx = subseqStartIdx + lengthParam - 1;
        currSubseqLen = (subseqEndIdx - subseqStartIdx) + 1;
        currSubseqSum = sum(seq(subseqStartIdx:subseqEndIdx));
        currSubseqMean = currSubseqSum/currSubseqLen;
        while (subseqEndIdx < seqLen) && (seq(subseqEndIdx + 1) <= currSubseqMean)
            subseqEndIdx = subseqEndIdx + 1;
            currSubseqLen = currSubseqLen + 1;
            currSubseqSum = currSubseqSum + seq(subseqEndIdx);
            currSubseqMean = currSubseqSum/currSubseqLen;
        end
        if currSubseqMean <= thresholdParam
            arrIdx = arrIdx + 1;
            lcmaSegments(arrIdx, 1:2) = [subseqStartIdx, subseqEndIdx];
        end
    end
    lcmaSegments = lcmaSegments(1:arrIdx, 1:2);

    %Merge overlapping LCMAs:

    for arrIdx = arrIdx:-1:2
        currStartVal = lcmaSegments(arrIdx, 1); 
        currEndVal = lcmaSegments(arrIdx, 2);
        prevEndVal = lcmaSegments(arrIdx - 1, 2);
        %Note to self: Maybe it should be '<=' below
        if (currEndVal <= prevEndVal)
            lcmaSegments(arrIdx, :) = [];
        elseif (currStartVal <= prevEndVal)
            lcmaSegments(arrIdx - 1, 2) = currEndVal;
            lcmaSegments(arrIdx, :) = [];
        end
    end
end