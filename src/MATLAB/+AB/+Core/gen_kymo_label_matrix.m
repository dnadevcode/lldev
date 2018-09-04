function [labelFlipbook] = gen_kymo_label_matrix(kymosEdgeIdxs, movieSz)
    numKymos = length(kymosEdgeIdxs);

    if numKymos <= intmax('uint8')
        dataType = 'uint8';
    elseif numKymos <= intmax('uint16')
        dataType = 'uint16';
    elseif numKymos <= intmax('uint32')
        dataType = 'uint32';
    else
        dataType = 'double';
    end

    movieSz = [movieSz, ones(1, max(0, 4 - length(movieSz)))];
    numFrames = movieSz(4);
    reindexing = 1:length(movieSz);
    reindexing(1:4) = [4, 1, 3, 2];
    flipbookSz = movieSz(reindexing);
    labelFlipbook = zeros(flipbookSz, dataType);
    for kymoNum = 1:numKymos
        tmpEdgeIdxs = kymosEdgeIdxs{kymoNum};
        emptyFrames = any(isnan(tmpEdgeIdxs), 2);
        for frameNum = 1:numFrames
            if emptyFrames(frameNum)
                continue;
            end
            tmpFrameEdgeIdxs = tmpEdgeIdxs(frameNum, :);
            rowStartIdx = tmpFrameEdgeIdxs(1);
            colIdx = tmpFrameEdgeIdxs(2);
            rowEndIdx = tmpFrameEdgeIdxs(3);
            labelFlipbook(frameNum, rowStartIdx:rowEndIdx, 1, colIdx) = kymoNum;
        end
    end
end