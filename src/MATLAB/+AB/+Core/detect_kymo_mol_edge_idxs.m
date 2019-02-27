function [kymoMolEdgeIdxs, ccIdxs] = detect_kymo_mol_edge_idxs(ccStruct, kymoEdgeDetectionSettings)
    % detect_kymo_mol_edge_idxs
    %
    % :param ccStruct: input parameter.
    % :param kymoEdgeDetectionSettings: input parameter.

    % :returns: kymoMolEdgeIdxs,ccIdxs
    
    % rewritten by Albertas Dvirnas
    
    movieSz = ccStruct.ImageSize;
    numCCs = ccStruct.NumObjects;

    numCols = movieSz(2);
    numFrames = movieSz(3);
    % ccColPresenceCounts = zeros(numCols, numCCs);
    labelFlipbookA = labelmatrix(ccStruct); % todo: avoid unneccessary memory hogging

    import Fancy.Utils.multidim_sum;

    % aggregation distance: kymo mask will be true for pixel of cc
    % if cc presence within aggColDist columns of a peak column
    % for cc (excluding lower column peaks with overlap)
    
    windowWidth = kymoEdgeDetectionSettings.windowWidth;
    aggColDist = floor(windowWidth/2);
    kymoMolEdgeIdxs = cell(numCCs, 1);
    m1expand = kymoEdgeDetectionSettings.morphExpansion;
    m1shrink = kymoEdgeDetectionSettings.morphShrinking;
    m1 = true(1, 1 + 2*m1expand);
    m2 = true(1, 1 + 2*(m1expand + m1shrink));
    m3 = true(1, 1 + 2*m1shrink);
    for ccNum = 1:numCCs
        % current molecule mask
        ccMaskFlipbookA = (labelFlipbookA == ccNum);
        
        % this might be two molecules that merge at some point, we should
        % be able to distinguish such cases
        ccPresenceTmp = sum(sum(ccMaskFlipbookA,3),1);
        [ccPeakPresenceTmp, ccPeakColIdxs] = findpeaks(ccPresenceTmp(:));

        [ccPeakPresenceTmp, ccSoTmp] = sort(ccPeakPresenceTmp, 'descend'); %#ok<ASGLU>
        ccPeakColIdxs = ccPeakColIdxs(1); % we should take maximum, I don't
        numPeaks = 1; % add deteciton for second peak when this is well tested..
        
        % if there are two, then we find the place where they merged..
        % if they are too close, could be merged in both directions..
        
        % know what happens if we have to peaks, we shouldn't have two
        % peaks here..
%         ccSkipPeakMaskTmp = false(1, length(ccPeakColIdxs));
%         % ccColPresenceCounts(:, ccNum) = ccPresence;
%         numPeaks = length(ccPeakColIdxs);
%         for peakNum = 1:numPeaks
%             if not(ccSkipPeakMaskTmp(peakNum))
%                 % exclude lower peaks with any aggregation overlap
%                 ccSkipPeakMaskTmp(setdiff(find(abs(ccPeakColIdxs - ccPeakColIdxs(peakNum)) <= 2*aggColDist), peakNum)) = true;
%             end
%         end
%         ccPeakColIdxs = ccPeakColIdxs(~ccSkipPeakMaskTmp);
%         numPeaks = length(ccPeakColIdxs);
        kymoMolEdgeIdxs{ccNum} = cell(numPeaks, 1);
        goodPeaksMask = false(numPeaks, 1);
        for peakNum = 1:numPeaks
            ccPeakColIdx = ccPeakColIdxs(peakNum);
            relevantColIdxs = max(1, ccPeakColIdx - aggColDist):min(numCols, ccPeakColIdx + aggColDist);

            rowStartIdxs = NaN(numFrames, 1);
            rowEndIdxs = rowStartIdxs;
            colIdxs = rowStartIdxs;

            for frameNum = 1:numFrames
                tmpRowMask = ccMaskFlipbookA(:, relevantColIdxs,frameNum);
                
                % this is not necessary for small windowWidth
                tmpRowMask = any(imdilate(imerode(imdilate(tmpRowMask, m1), m2), m3),2);
                
                rowStartIdx = find(tmpRowMask, 1, 'first');
                if not(isempty(rowStartIdx))
                    rowEndIdx = find(tmpRowMask, 1, 'last');
                    rowStartIdxs(frameNum) = rowStartIdx;
                    rowEndIdxs(frameNum) = rowEndIdx;
                    colIdxs(frameNum) = ccPeakColIdx; % in reality could adjust this in case the angle was not computed correctly..
                end
            end
            
            edgeIdxs = cat(3, [rowStartIdxs, colIdxs], [rowEndIdxs, colIdxs]);
            kymoMolEdgeIdxs{ccNum}{peakNum} = edgeIdxs;
            hasNonnan = any(not(isnan(edgeIdxs)), 1); % must have a nonnan value for every type of edge (row/col - start/end)
            goodPeaksMask(peakNum) = all(hasNonnan(:));
        end
        kymoMolEdgeIdxs{ccNum} = kymoMolEdgeIdxs{ccNum}(goodPeaksMask);
    end

    % flatten kymosEdgePts  a bit by not differentiating into cells based
    %   on their ccNum, but first generate a ccIdxs array first so the
    %   flattened indices can still be associated with their cc
    ccKymoCounts = cellfun(@length, kymoMolEdgeIdxs);
    ccIdxs = (1:numCCs)';
    ccIdxs = arrayfun(@(ccNum, kymoCount) repmat(ccNum, [kymoCount, 1]), ccIdxs, ccKymoCounts, 'UniformOutput', false);
    ccIdxs = vertcat(ccIdxs{:});
    kymoMolEdgeIdxs = vertcat(kymoMolEdgeIdxs{:});
end