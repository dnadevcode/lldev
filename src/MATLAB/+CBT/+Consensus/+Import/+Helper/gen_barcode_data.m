function [barcodeGenData] = gen_barcode_data(alignedKymo, detectEdges)

    if nargin < 2
        detectEdges = 1;
    end
        
    if detectEdges==1
        skipDoubleTanhAdjustment = true;
        import OptMap.MoleculeDetection.EdgeDetection.get_default_edge_detection_settings;
        edgeDetectionSettings = get_default_edge_detection_settings(skipDoubleTanhAdjustment);

        import OptMap.MoleculeDetection.EdgeDetection.approx_main_kymo_molecule_edges;
        [leftEdgeIdxs, rightEdgeIdxs, alignedKymoMoleculeMask] = approx_main_kymo_molecule_edges(alignedKymo, edgeDetectionSettings);

        barcodeGenData.leftEdgeIdxs = leftEdgeIdxs;
        barcodeGenData.rightEdgeIdxs = rightEdgeIdxs;

        leftEdgeIdx = round(nanmean(leftEdgeIdxs));
        rightEdgeIdx = round(nanmean(rightEdgeIdxs));

        if rightEdgeIdx <= leftEdgeIdx
            disp('ah');
        end
    else
        barcodeGenData.leftEdgeIdxs = ones(1,size(alignedKymo,1));
        barcodeGenData.rightEdgeIdxs =  size(alignedKymo,2)*ones(1,size(alignedKymo,1));

        leftEdgeIdx = 1;
        rightEdgeIdx = size(alignedKymo,2);        
    end

    % Determine indices for rotated barcode with background cropped out
    barcodeIdxs = leftEdgeIdx:rightEdgeIdx;
    rawBarcode = nanmean(alignedKymo, 1);

    if detectEdges==1

        bgIndices = true(1, size(alignedKymo, 2));
        bgIndices(barcodeIdxs) = 0;


        nonBarcodeVals = alignedKymo(:, bgIndices);
        nonBarcodeVals = nonBarcodeVals(:);
        nonBarcodeDistFit = fitdist(nonBarcodeVals, 'Normal');
        barcodeGenData.bgMeanApprox =  nonBarcodeDistFit.mu;
        barcodeGenData.bgStdApprox = nonBarcodeDistFit.sigma;
        rawBg = nanmean(rawBarcode(bgIndices));
        barcodeGenData.rawBg = rawBg;

    else
        barcodeGenData.bgMeanApprox =  nan;
        barcodeGenData.bgStdApprox = nan; 
        barcodeGenData.rawBg = nan;
    end
    

    barcodeGenData.rawBarcode = rawBarcode(barcodeIdxs);

    barcodeGenData.rawBarcodeLeftEdgeIndex = leftEdgeIdx;
    barcodeGenData.rawBarcodeRightEdgeIndex = rightEdgeIdx;
end
