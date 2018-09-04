function[ccValsUnflipped, ccValsFlipped] = calc_ccs_mats(refBarcode, croppedContigBarcodes, isPlasmidTF, isFullyCoveredTF)
    import CBT.ExpComparison.Core.GrossCcorr.ccorr_all;
    numContigs2 = length(croppedContigBarcodes);
    ccValsUnflipped = NaN(numContigs2, 1);
    ccValsFlipped = NaN(numContigs2, 1);
    for contigNum2 = 1:numContigs2
        contig = croppedContigBarcodes{contigNum2};
        [ccValsUnflipped, ccValsFlipped, flipContigsTF] = ccorr_all(...
            contig, ...
            refBarcode, ...
            isPlasmidTF, ...
            not(isFullyCoveredTF) ...
        );
        if flipContigsTF
            [ccValsUnflipped, ccValsFlipped] = deal(ccValsFlipped, ccValsUnflipped);
        end
        ccValsUnflipped(contigNum2) = ccValsUnflipped;
        ccValsFlipped(contigNum2) = ccValsFlipped;
    end
end