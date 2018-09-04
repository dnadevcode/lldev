function [kymosEdgePts] = translate_kymos_edge_coords(kymosEdgeIdxs, rRot, cRot)
    numKymos = length(kymosEdgeIdxs);
    kymosEdgePts = cell(numKymos, 1);
    for kymoNum = 1:numKymos
        tmpEdgeIdxs = kymosEdgeIdxs{kymoNum};
        numFrames = size(tmpEdgeIdxs, 1);

        startEdgePts = nan(numFrames, 2);
        endEdgePts = nan(numFrames, 2);

        for frameNum = 1:numFrames
            startIdxs = tmpEdgeIdxs(frameNum, :, 1);
            if not(any(isnan(startIdxs)))
                rowStartIdx = startIdxs(1);
                colStartIdx = startIdxs(2);
                startEdgePts(frameNum, :) = [rRot(rowStartIdx, colStartIdx), cRot(rowStartIdx, colStartIdx)];
            end
            endIdxs = tmpEdgeIdxs(frameNum, :, 2);
            if not(any(isnan(endIdxs)))
                rowEndIdx = endIdxs(1);
                colEndIdx = endIdxs(2);
                endEdgePts(frameNum, :) = [rRot(rowEndIdx, colEndIdx), cRot(rowEndIdx, colEndIdx)];
            end
        end
        kymosEdgePts{kymoNum} = cat(3, startEdgePts, endEdgePts);
    end
end