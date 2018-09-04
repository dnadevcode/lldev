function [barcodeGenData, filterSettings] = gen_barcode_data(alignedKymo,barcodeConsensusSettings,filterSettings)
    skipDoubleTanhAdjustment = true;
    
    % todo: use edge detection only if the edges have not been computed beforehand,
    % when aligning kymo.
    import OptMap.MoleculeDetection.EdgeDetection.get_default_edge_detection_settings;
    edgeDetectionSettings = get_default_edge_detection_settings(skipDoubleTanhAdjustment);

    import OptMap.MoleculeDetection.EdgeDetection.approx_main_kymo_molecule_edges;
    [leftEdgeIdxs, rightEdgeIdxs, alignedKymoMoleculeMask] = approx_main_kymo_molecule_edges(alignedKymo, edgeDetectionSettings);
    
    leftEdgeIdx = round(nanmean(leftEdgeIdxs));
    rightEdgeIdx = round(nanmean(rightEdgeIdxs));
    
    if rightEdgeIdx <= leftEdgeIdx
        disp('ah');
    end
    
    % Determine indices for rotated barcode with background cropped out
    barcodeIdxs = leftEdgeIdx:rightEdgeIdx;
    rawBarcode = nanmean(alignedKymo, 1);
    
% 
%     % If kymographs are only one row
%     if filterSettings.filter==1 
%         filterSize = barcodeConsensusSettings.psfSigmaWidth_nm/barcodeConsensusSettings.prestretchPixelWidth_nm;
%         if filterSettings.timeFramesNr==1
%         	rawBarcodeFiltered = nanmean(imgaussfilt(alignedKymo(1,:), filterSize),1);
%         else
%         	rawBarcodeFiltered = nanmean(imgaussfilt(alignedKymo(1:min(filterSettings.timeFramesNr,size(alignedKymo,1)),:), filterSize));
%         end
%     else
%         rawBarcodeFiltered = [];
%     end


    bgIndices = true(1, size(alignedKymo, 2));


    bgIndices(barcodeIdxs) = 0;

    nonBarcodeVals = alignedKymo(:, bgIndices);
    nonBarcodeVals = nonBarcodeVals(:);
    nonBarcodeDistFit = fitdist(nonBarcodeVals, 'Normal');
    barcodeGenData.bgMeanApprox =  nonBarcodeDistFit.mu;
    barcodeGenData.bgStdApprox = nonBarcodeDistFit.sigma;
    
    rawBg = nanmean(rawBarcode(bgIndices));
  
    barcodeGenData.rawBarcode = rawBarcode(barcodeIdxs);
%     if ~isempty(rawBarcodeFiltered)
%         barcodeGenData.rawBarcodeFiltered = rawBarcodeFiltered(barcodeIdxs);
%     end
    barcodeGenData.rawBarcodeLeftEdgeIndex = leftEdgeIdx;
    barcodeGenData.rawBarcodeRightEdgeIndex = rightEdgeIdx;
    barcodeGenData.rawBg = rawBg;
end
