function [] = hacky_consensus_diff_hunter(consensusFilepaths, consensusFilepathsFixed)
    % Summer 2016
    %  there 

    import SignalRegistration.Xcorr.masked_norm_xcorr_fft;
    numFiles = length(consensusFilepaths);
    for fileNum=1:numFiles
        fpath = consensusFilepaths{fileNum};
        fpathFixed = consensusFilepathsFixed{fileNum};
        
        structUnfixed = load(fpath);
        structUnfixed = structUnfixed.clusterConsensusData;
        
        structFixed = load(fpathFixed);
        structFixed = structFixed.clusterConsensusData;
        
        consensusBarcodeUnfixed = structUnfixed.barcode;
        consensusBitmaskUnfixed = structUnfixed.bitmask;
        
        consensusBarcodeFixed = structFixed.barcode;
        consensusBitmaskFixed = structFixed.bitmask;

        if (isequal(consensusBarcodeUnfixed, consensusBarcodeFixed)) && (isequal(consensusBitmaskUnfixed, consensusBitmaskFixed))
            continue;
        end

        %hacky/lazy trick
        % negating values where bitmask is set to false so differences
        %  in the bitmasks manifest themselves in lower
        %  correlations
        consensusBarcodeUnfixed(~consensusBitmaskUnfixed) = -100 * consensusBarcodeUnfixed(~consensusBitmaskUnfixed);
        consensusBarcodeFixed(~consensusBitmaskFixed) = -100 * consensusBarcodeFixed(~consensusBitmaskFixed);
        
        unflippedXcorrMax = max(masked_norm_xcorr_fft(consensusBarcodeUnfixed(:), consensusBarcodeFixed(:), true(size(consensusBarcodeUnfixed(:))), true(size(consensusBarcodeFixed(:))), true));
        flippedXcorrMax = max(masked_norm_xcorr_fft(flipud(consensusBarcodeUnfixed(:)), (consensusBarcodeFixed(:)), flipud(true(size(consensusBarcodeUnfixed(:)))), (true(size(consensusBarcodeFixed(:)))), true));
        
        xcorrMax = max(unflippedXcorrMax, flippedXcorrMax);
        disp(fpath);
        disp(1 - xcorrMax); %should be 0 if all is good
    end
end