function [ barcodeGen,acceptedBars ] = gen_barcodes_from_kymo( kymoStructs, sets,maxLen )
    % gen_barcodes_from_kymo
    % generates barcodes from aligned kymograph data
    %
    %     Args:
    %         sets: settings structure
    %         kymoStructs: structure file for kymographs
    % 
    %     Returns:
    %         barcodeGen: barcode data
    
    if nargin < 3
        maxLen = inf;
    end
    % number of barcodes
    numBar = length(kymoStructs);
    
    % predefine cell for barcode structure
    barcodeGen = cell(1,numBar);
    
    disp('Starting generating barcodes...')
    tic
    % this computes barcode structure for nralign or other alignment methods 
    import DBM4.gen_barcode_data;
    for i=1:numBar 
        % generate barcode data
        if ~isempty(kymoStructs{i}.leftEdgeIdxs)
            [barcodeGen{i}] = gen_barcode_data(kymoStructs{i}.alignedKymo,kymoStructs{i}.leftEdgeIdxs, kymoStructs{i}.rightEdgeIdxs,sets.skipEdgeDetection);
        else
            barcodeGen{i}.rawBarcode = [];
        end

        barcodeGen{i}.name =  kymoStructs{i}.name;
        barcodeGen{i}.kymoIdx = i;
    end
   
    %% Now define bitmasks
    % untrusted number of pixels, also will change if stretchfactor is
    % introduced
    untrPx = sets.bitmasking.untrustedPx;

	import CBT.Bitmasking.generate_zero_edged_bitmask_row;
    % add bitmasks. TODO: Also consider if there could be NAN's in the middle of
    % the molecule (due to, i.e., fragmentation)
    for i=1:numBar
        % add standard bitmask where pixels in the beginning and the end
        % are ignored
        barcodeGen{i}.rawBitmask = generate_zero_edged_bitmask_row(length(barcodeGen{i}.rawBarcode),round(untrPx));
        % in case some untrusted pixels in the middle (i.e. due to two
        % molecules being close to each other), bitmask this region
        barcodeGen{i}.rawBarcode(isnan(barcodeGen{i}.rawBarcode)) = false;
    end
    
        % filter out short barcodes
    barLens = cellfun(@(x) sum(x.rawBitmask),barcodeGen);
    acceptedBars = find((barLens>=sets.minLen).*(barLens<=maxLen));
    barcodeGen = barcodeGen(acceptedBars);
%     barLens = cellfun(@(x) sum(x.rawBitmask),barcodeGen);
%     barcodeGen = barcodeGen(barLens<=maxLen);

    disp(strcat([num2str(length(barcodeGen)) ' passing length threshold: length >= ' num2str(sets.minLen)]));


    timePassed = toc;
    disp(strcat(['All barcodes generated in ' num2str(timePassed) ' seconds']));

end

