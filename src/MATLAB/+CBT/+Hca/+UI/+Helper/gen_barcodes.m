function [ hcaSessionStruct ] = gen_barcodes( hcaSessionStruct, sets )
    % gen_barcodes
    
    % input hcaSessionStruct, sets
    
    % output hcaSessionStruct
    disp('Starting generating barcodes...')
    tic

    % Based on the alignment method chosen, we either use the ssd structure to generate data, or the nralign structure 
    if sets.alignMethod==1
        % this computes the barcode structure for ssd
        import CBT.Hca.UI.Helper.gen_barcode_data_ssd;
        for i=1:length(hcaSessionStruct.unalignedKymos)  
            [hcaSessionStruct.barcodeGen{i}] = gen_barcode_data_ssd(hcaSessionStruct.alignedKymo{i}(1:min(end,sets.timeFramesNr),:),hcaSessionStruct.alignedKymBitMask{i}(1:min(end,sets.timeFramesNr),:),hcaSessionStruct.backgroundKym{i}(1:min(end,sets.timeFramesNr),:));
        end
    else
        % this computes barcode structure for nralign or other alignment
        % methods (wpalign)
        import CBT.Hca.UI.Helper.gen_barcode_data;
        for i=1:length(hcaSessionStruct.unalignedKymos) 
            [hcaSessionStruct.barcodeGen{i}] = gen_barcode_data(hcaSessionStruct.alignedKymo{i}(1:min(end,sets.timeFramesNr),:),sets.barcodeConsensusSettings,sets.filterSettings);
        end
    end

    % define barcodes
    rawBarcodes = cellfun(@(xx) xx.rawBarcode, hcaSessionStruct.barcodeGen,'UniformOutput',false);

    % their lengths
    lens = cellfun(@length,rawBarcodes);
    for i=1:length(rawBarcodes)
    	hcaSessionStruct.lengths(i) = length(rawBarcodes{i});
    end
    % and bitmasks
    rawBitmasks = cell(1,length(lens));

    % now define filtered barcodes
    
    % if filtered was selected
    if sets.filterSettings.filter == 1
        % create structure
        hcaSessionStruct.barcodeGenFiltered = cell(length(hcaSessionStruct.unalignedKymos),1);

        % go through all the kymo's
        for i=1:length(hcaSessionStruct.unalignedKymos)
            % the number of timeframes is the minimum between number of time frames and
            % the length of the kymo
            indx = 1:min(sets.filterSettings.timeFramesNr,size(hcaSessionStruct.alignedKymo{i},1));
            hcaSessionStruct.alignedKymoFiltered{i} = hcaSessionStruct.alignedKymo{i}(indx,:);

            % if we have chosen to filter before stretching
            % here filter size was chosen beforehand
            if sets.filterSettings.filterMethod ==1
                % todo: could vectorize filtering of rows here?
                for j=indx
                    indd = ~isnan(hcaSessionStruct.alignedKymo{i}(j,:));
                    hcaSessionStruct.alignedKymoFiltered{i}(j,indd) = imgaussfilt(hcaSessionStruct.alignedKymo{i}(j,indd), sets.filterSettings.filterSize);    
                end
            end

            % now depending on which alignment method, extract data
            if sets.alignMethod==1
                import CBT.Hca.UI.Helper.gen_barcode_data_ssd;
                [hcaSessionStruct.barcodeGenFiltered{i}] = gen_barcode_data_ssd(hcaSessionStruct.alignedKymoFiltered{i},hcaSessionStruct.alignedKymBitMask{i}(1:min(sets.filterSettings.timeFramesNr,size(hcaSessionStruct.alignedKymo{i},1)),:),hcaSessionStruct.backgroundKym{i}(1:min(sets.filterSettings.timeFramesNr,size(hcaSessionStruct.alignedKymo{i},1)),:));
            else
                % this method needs to run edge detection because they were
                % not find from the kymo alignment procedure
                import CBT.Hca.UI.Helper.gen_barcode_data;
                [hcaSessionStruct.barcodeGenFiltered{i}] = gen_barcode_data(hcaSessionStruct.alignedKymoFiltered{i},sets.barcodeConsensusSettings,sets.filterSettings);
            end
        end

        % and these are the filtered barcodes (or unfiltered still if no
        % pre-filtering is done
        rawBarcodesFiltered = cellfun(@(xx) xx.rawBarcode, hcaSessionStruct.barcodeGenFiltered,'UniformOutput',false);
        lensFiltered = cellfun(@length,rawBarcodesFiltered);
        rawBitmasksFiltered = cell(1,length(lensFiltered));
        for i=1:length(rawBarcodesFiltered)
        	hcaSessionStruct.lengthsFiltered(i) = length(rawBarcodesFiltered{i});
        end
    else
        rawBarcodesFiltered = [];
        rawBitmasksFiltered = [];
    end
    % define bitmasks
    
    % stretch factors. Todo: these will be different in case each molecule
    % has different bp/nm extension
    
    stretchFactors = ones(1,length(hcaSessionStruct.barcodeGen));
    
    % untrusted number of pixels, also will change if stretchfactor is
    % introduced
    untrPx = sets.barcodeConsensusSettings.prestretchUntrustedEdgeLenUnrounded_pixels;

    import CBT.Bitmasking.generate_zero_edged_bitmask_row;

    % add bitmasks
    for i=1:length(lens)
        rawBitmasks{i} = generate_zero_edged_bitmask_row(lens(i),round(stretchFactors(i) * untrPx));
        if sets.filterSettings.filter == 1
            rawBitmasksFiltered{i} = generate_zero_edged_bitmask_row(lensFiltered(i),round(stretchFactors(i) * untrPx));
        end
    end
    
    % convert to common length
    if  sets.prestretchMethod == 1
        commonLength = ceil(mean(lens));

        import CBT.Consensus.Core.convert_barcodes_to_common_length;
        [rawBarcodes] = convert_barcodes_to_common_length(rawBarcodes, commonLength);
        
        import CBT.Consensus.Core.convert_bitmasks_to_common_length;
        [rawBitmasks] = convert_bitmasks_to_common_length(rawBitmasks, commonLength);
        for i=1:length(rawBarcodes)
            hcaSessionStruct.lengths(i) = length(rawBarcodes{i});
        end
        if sets.filterSettings.filter == 1
            commonLength = ceil(mean(lensFiltered));
            [rawBarcodesFiltered] = convert_barcodes_to_common_length(rawBarcodesFiltered, commonLength);
              
            import CBT.Consensus.Core.convert_bitmasks_to_common_length;
            [rawBitmasksFiltered] = convert_bitmasks_to_common_length(rawBitmasksFiltered, commonLength);
    
            for i=1:length(rawBarcodesFiltered)
                hcaSessionStruct.lengthsFiltered(i) = length(rawBarcodesFiltered{i});
            end
        end

    end
    
    if size(rawBarcodes,2)>size(rawBarcodes,1)
    	rawBarcodes = rawBarcodes';
    end
    
    hcaSessionStruct.rawBarcodes = rawBarcodes;
    hcaSessionStruct.rawBitmasks = rawBitmasks;
 
            
     if size(rawBarcodesFiltered,2)>size(rawBarcodesFiltered,1)
            rawBarcodesFiltered = rawBarcodesFiltered';
     end
        
    hcaSessionStruct.rawBarcodesFiltered = rawBarcodesFiltered;
    hcaSessionStruct.rawBitmasksFiltered = rawBitmasksFiltered;     

    timePassed = toc;
    disp(strcat(['All barcodes generated in ' num2str(timePassed) ' seconds']));

end

