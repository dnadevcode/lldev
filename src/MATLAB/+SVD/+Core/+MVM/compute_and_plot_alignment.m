% function compute_and_plot_alignment(hAxis, barcode1, barcode2, pathCoordinates)
%     % Plots the longer barcode repeated twice together with the
%     %  other barcode warped according to the alignment path in a new
%     %  figure
%     
%     if length(barcode2) < length(barcode1)
%         [barcodeSmaller, barcodeBigger] = deal(barcode2, barcode1);
%     end
%     refBarcodeX2 = repmat(barcodeBigger, [2, 1]);
%     warpedBarcode = barcodeSmaller;
%     
%     refBarcodeX2Len = length(refBarcodeX2);
%     import SVD.Core.compute_aligned_seq;
%     alignedSeq = compute_aligned_seq(refBarcodeX2Len, warpedBarcode, pathCoordinates);
%     
%     import SVD.UI.plot_alignment;
%     plot_alignment(hAxis, alignedSeq, refBarcodeX2);
% end