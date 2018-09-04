function expCurveBitmask = get_std_experiment_bitmask(curveLen, deltaCut, psfSigmaWidth_nm, pixelWidth_nm)
    edgeLen = round(deltaCut*psfSigmaWidth_nm/pixelWidth_nm);
    expCurveBitmask = true(1, curveLen);
    edgeIndices = [(1:min(curveLen, edgeLen)), ((max(curveLen, edgeLen) - edgeLen + 1):curveLen)];
    expCurveBitmask(edgeIndices) = false;
end