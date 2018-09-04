function [kymoMolEdgeIdxs, ccIdxs] = detect_kymo_mol_edge_idxs(ccStruct, kymoEdgeDetectionSettings)
    movieSz = ccStruct.ImageSize;
    numCCs = ccStruct.NumObjects;

    
    
    movieSz = [movieSz, ones(1, max(0, 4 - length(movieSz)))];
    numCols = movieSz(2);
    numFrames = movieSz(4);
    % ccColPresenceCounts = zeros(numCols, numCCs);
    labelFlipbookA = permute(labelmatrix(ccStruct), [4 1 3 2]); % todo: avoid unneccessary memory hogging

    import Fancy.Utils.multidim_sum;
    import Fancy.UI.ProgressFeedback.BasicTextProgressMessenger;
    progress_messenger = BasicTextProgressMessenger.get_instance();
    msgOnInit = sprintf(' Finding kymo edges from  %d connected components...\n', numCCs);
    progress_messenger.init(msgOnInit);

    % aggregation distance: kymo mask will be true for pixel of cc
    % if cc presence within aggColDist columns of a peak column
    % for cc (excluding lower column peaks with overlap)
    windowWidth = 3;
    aggColDist = floor(windowWidth/2);
    kymoMolEdgeIdxs = cell(numCCs, 1);
    m1expand = kymoEdgeDetectionSettings.morphExpansion;
    m1shrink = kymoEdgeDetectionSettings.morphShrinking;
    m1 = true(1, 1 + 2*m1expand);
    m2 = true(1, 1 + 2*(m1expand + m1shrink));
    m3 = true(1, 1 + 2*m1shrink);
    for ccNum = 1:numCCs
        ccMaskFlipbookA = (labelFlipbookA == ccNum);
        ccPresenceTmp = multidim_sum(ccMaskFlipbookA, [1 2 3]);
        [ccPeakPresenceTmp, ccPeakColIdxs] = findpeaks(ccPresenceTmp(:));
        [ccPeakPresenceTmp, ccSoTmp] = sort(ccPeakPresenceTmp, 'descend'); %#ok<ASGLU>
        ccPeakColIdxs = ccPeakColIdxs(ccSoTmp);
        ccSkipPeakMaskTmp = false(1, length(ccPeakColIdxs));
        % ccColPresenceCounts(:, ccNum) = ccPresence;
        numPeaks = length(ccPeakColIdxs);
        for peakNum = 1:numPeaks
            if not(ccSkipPeakMaskTmp(peakNum))
                % exclude lower peaks with any aggregation overlap
                ccSkipPeakMaskTmp(setdiff(find(abs(ccPeakColIdxs - ccPeakColIdxs(peakNum)) <= 2*aggColDist), peakNum)) = true;
            end
        end
        ccPeakColIdxs = ccPeakColIdxs(~ccSkipPeakMaskTmp);
        numPeaks = length(ccPeakColIdxs);
        kymoMolEdgeIdxs{ccNum} = cell(numPeaks, 1);
        goodPeaksMask = false(numPeaks, 1);
        for peakNum = 1:numPeaks
            ccPeakColIdx = ccPeakColIdxs(peakNum);
            relevantColIdxs = max(1, ccPeakColIdx - aggColDist):min(numCols, ccPeakColIdx + aggColDist);

            rowStartIdxs = NaN(numFrames, 1);
            rowEndIdxs = rowStartIdxs;
            colIdxs = rowStartIdxs;

            for frameNum = 1:numFrames
                tmpRowMask = any(ccMaskFlipbookA(frameNum, :, 1, relevantColIdxs), 4);
                tmpRowMask = imdilate(imerode(imdilate(tmpRowMask, m1), m2), m3);
                rowStartIdx = find(tmpRowMask, 1, 'first');
                if not(isempty(rowStartIdx))
                    rowEndIdx = find(tmpRowMask, 1, 'last');
                    rowStartIdxs(frameNum) = rowStartIdx;
                    rowEndIdxs(frameNum) = rowEndIdx;
                    colIdxs(frameNum) = ccPeakColIdx;
                end
            end
            
            edgeIdxs = cat(3, [rowStartIdxs, colIdxs], [rowEndIdxs, colIdxs]);
            kymoMolEdgeIdxs{ccNum}{peakNum} = edgeIdxs;
            hasNonnan = any(not(isnan(edgeIdxs)), 1); % must have a nonnan value for every type of edge (row/col - start/end)
            goodPeaksMask(peakNum) = all(hasNonnan(:));
        end
        kymoMolEdgeIdxs{ccNum} = kymoMolEdgeIdxs{ccNum}(goodPeaksMask);
        progress_messenger.checkin(ccNum, numCCs);
    end

    % flatten kymosEdgePts  a bit by not differentiating into cells based
    %   on their ccNum, but first generate a ccIdxs array first so the
    %   flattened indices can still be associated with their cc
    ccKymoCounts = cellfun(@length, kymoMolEdgeIdxs);
    ccIdxs = (1:numCCs)';
    ccIdxs = arrayfun(@(ccNum, kymoCount) repmat(ccNum, [kymoCount, 1]), ccIdxs, ccKymoCounts, 'UniformOutput', false);
    ccIdxs = vertcat(ccIdxs{:});
    kymoMolEdgeIdxs = vertcat(kymoMolEdgeIdxs{:});

    msgOnCompletion = sprintf('    Finished finding kymos for all %d connected components\n', numCCs);
    progress_messenger.finalize(msgOnCompletion);
end