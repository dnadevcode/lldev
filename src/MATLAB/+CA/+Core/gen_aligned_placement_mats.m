function [refContigPlacementIdxsMat, refContigPlacementValsMat] = gen_aligned_placement_mats(refBarcodeLen_pixels, placedContigBarcodes, contigPlacementOptionIdxs)
    numPlacedContigs = length(placedContigBarcodes);

    flippedContigMask = contigPlacementOptionIdxs > refBarcodeLen_pixels;

    placedContigStartPosIdxs = contigPlacementOptionIdxs;
    %TODO: deal with any non-placed barcodes that may have been passed to
    % this function
    % By convention contigPlacementOptionIdxs, where N is refBarcodeLen:
    %  unflipped: x in [1:N] so pos. along ref barcode is just x
    %  flipped: x in [N + (1:N)] so pos. along ref barcode is x - N
    %  if non-placement allowed, [2*N + 1]
    placedContigStartPosIdxs(flippedContigMask) = placedContigStartPosIdxs(flippedContigMask) - refBarcodeLen_pixels;

    refContigPlacementIdxsMat = NaN(refBarcodeLen_pixels, numPlacedContigs);
    refContigPlacementValsMat = refContigPlacementIdxsMat;
    for placedContigNum = 1:numPlacedContigs
        placedContigBarcode = placedContigBarcodes{placedContigNum};
        placedContigStartPosIdx = placedContigStartPosIdxs(placedContigNum);
        flippedContigTF = flippedContigMask(placedContigNum);

        placedContigBarcodeLen = length(placedContigBarcode);
        placedContigPixelIdxs = (1:placedContigBarcodeLen)';
        placedContigPixelRefIdxs = flip(1 + mod(-1 + placedContigStartPosIdx - 1 + placedContigPixelIdxs, refBarcodeLen_pixels), 2 - flippedContigTF);
        refContigPlacementIdxsMat(placedContigPixelRefIdxs, placedContigNum) = placedContigPixelIdxs; % row # = pixel # along ref barcode, col # = placed contig #, val = idx along placed contig
        refContigPlacementValsMat(placedContigPixelRefIdxs, placedContigNum) = placedContigBarcode(:);
    end
end