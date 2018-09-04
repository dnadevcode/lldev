function [miniRotatedMoviesCoords] = get_molecule_movie_coords(rowEdgeIdxs, colCenterIdxs, rotatedMovieSz, rowSidePadding, colSidePadding)
    numRows = rotatedMovieSz(1);
    numFrames = rotatedMovieSz(3);
    numCols = rotatedMovieSz(2);


    rowEdgeIdxs(:,1) = max(rowEdgeIdxs(:,1) - rowSidePadding, 1);
    rowEdgeIdxs(:,2) = min(rowEdgeIdxs(:,2) + rowSidePadding, numRows);

    colCenterIdxs = min(max(colCenterIdxs, 1 + colSidePadding), numCols - colSidePadding);
    colEdgeIdxs = [colCenterIdxs - colSidePadding, colCenterIdxs + colSidePadding];

    startFrameIdx = 1;
    endFrameIdx = numFrames;
    numMoleculesDetected = size(rowEdgeIdxs, 1);
    frameEdgeIdxs = [zeros(numMoleculesDetected, 1) + startFrameIdx, zeros(numMoleculesDetected, 1) + endFrameIdx];

    miniRotatedMoviesCoords = permute(cat(3, rowEdgeIdxs, colEdgeIdxs, frameEdgeIdxs), [3 2 1]);
    miniRotatedMoviesCoords = arrayfun(@(moleculeNum) miniRotatedMoviesCoords(:, :, moleculeNum), (1:numMoleculesDetected)', 'UniformOutput', false);
end