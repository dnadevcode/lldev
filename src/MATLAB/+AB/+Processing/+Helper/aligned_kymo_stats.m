function [ meanAlignedKymos,stdAlignedKymos ,meanAlignedMask,barcodeEdges, barcodes, backgrounds] = aligned_kymo_stats(flattenedKymosAligned,kymoMasksAligned, tmp_numKymos )
    % aligned_kymo_stats

    % :param 1: 1
    % :param 2: 2
    %
    % :returns: meanAlignedKymos,stdAlignedKymos,
    % meanAlignedMask,barcodeEdges, barcodes, backgrounds

    % written by Albertas Dvirnas

    meanAlignedKymos = cell(tmp_numKymos, 1);
    stdAlignedKymos = cell(tmp_numKymos, 1);
    meanAlignedMask = cell(tmp_numKymos, 1);
    barcodeEdges = NaN(tmp_numKymos, 2);
    barcodes = cell(tmp_numKymos, 1);    
    backgrounds  = cell(tmp_numKymos, 1); 
    
    import Microscopy.Utils.segment_nonadj_data;
    for tmp_kymoIdx = 1:tmp_numKymos
        tmp_alignedKymo = flattenedKymosAligned{tmp_kymoIdx};
        tmp_alignedMask = kymoMasksAligned{tmp_kymoIdx};
        tmp_alignedMaskMean = mean(double(tmp_alignedMask), 1);
        tmp_meanAlignedKymo  = mean(tmp_alignedKymo, 1, 'omitnan');
        tmp_stdAlignedKymo  = std(tmp_alignedKymo, 0, 1, 'omitnan');
        
        [~, tmp_idxRanges] = segment_nonadj_data(find(tmp_alignedMaskMean > 0));
        tmp_rangeLens = diff(tmp_idxRanges, [], 2) + 1;
        [~, tmpMaxRangeLenIdx] = max(tmp_rangeLens);
        barcodeEdges(tmp_kymoIdx, 1:2) = tmp_idxRanges(tmpMaxRangeLenIdx, 1:2);
        
        % Determine indices for rotated barcode with background cropped out
        tmp_adjustedIndices = barcodeEdges(tmp_kymoIdx, 1):barcodeEdges(tmp_kymoIdx, 2);
        tmp_barcode = tmp_meanAlignedKymo(tmp_adjustedIndices);
        
        % determine background
        bgrPx = ones(1,length(tmp_meanAlignedKymo));
        bgrPx(tmp_adjustedIndices) = 0;
        tmp_background = tmp_meanAlignedKymo(logical(bgrPx));
     
        % rawBarcode = zscore(rawBarcode);
        meanAlignedKymos{tmp_kymoIdx} = tmp_meanAlignedKymo;
        meanAlignedMask{tmp_kymoIdx} = tmp_alignedMaskMean;
        stdAlignedKymos{tmp_kymoIdx} = tmp_stdAlignedKymo;
        barcodes{tmp_kymoIdx} = tmp_barcode;
        backgrounds{tmp_kymoIdx} = tmp_background;
    end
    
    
    
end

