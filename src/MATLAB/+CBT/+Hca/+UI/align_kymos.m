function [ hcaSessionStruct ] = align_kymos( sets,hcaSessionStruct )
    % align_kymos

    % input sets,hcaSessionStruct
    % output hcaSessionStruct

    unalignedKymos = hcaSessionStruct.unalignedKymos;

    disp('Starting kymo alignment...')
    tic
    % based on an alignment method choice
    if sets.alignMethod==1
        
        % import the unction file
        import CBT.Hca.Core.Comparison.ssd_align_first2;
        
        % simplify notation for settings
        barcodeConsensusSettings = sets.barcodeConsensusSettings;
        edgeDetectionSettings = sets.edgeDetectionSettings;
        
        % run a parfor loop
        parfor i=1:length(unalignedKymos)
            % make sure the kymo is double
            kymoToAlign = double(unalignedKymos{i});
            
            % run the alignment
            [ alignedKymo{i},unAlignedKymoMoleculeMask{i},alignedKymBitMask{i}, backgroundKym{i},ssdCoef{i}] = ssd_align_first2(kymoToAlign,barcodeConsensusSettings,edgeDetectionSettings,sets);
        end
        
        % put things in the session structure
        hcaSessionStruct.alignedKymo = alignedKymo;
        hcaSessionStruct.alignedKymBitMask = alignedKymBitMask;
        hcaSessionStruct.backgroundKym = backgroundKym;
        hcaSessionStruct.ssdCoef = ssdCoef;
        hcaSessionStruct.unAlignedKymoMoleculeMask =unAlignedKymoMoleculeMask;
    else
        if sets.alignMethod==3
            % import the unction file
            import CBT.Hca.Core.Comparison.ssd_align_first2;

            % simplify notation for settings
            barcodeConsensusSettings = sets.barcodeConsensusSettings;
            edgeDetectionSettings = sets.edgeDetectionSettings;

            % run a parfor loop
            parfor i=1:length(unalignedKymos)
                % make sure the kymo is double
                kymoToAlign = double(unalignedKymos{i});

                % run the alignment
                [ alignedKymo{i},unAlignedKymoMoleculeMask{i},alignedKymBitMask{i}, backgroundKym{i},ssdCoef{i}] = ssd_align_first2(kymoToAlign,barcodeConsensusSettings,edgeDetectionSettings,sets);
            end

            % put things in the session structure
            hcaSessionStruct.alignedKymo = alignedKymo;
            hcaSessionStruct.alignedKymBitMask = alignedKymBitMask;
            hcaSessionStruct.backgroundKym = backgroundKym;
            hcaSessionStruct.ssdCoef = ssdCoef;
            hcaSessionStruct.unAlignedKymoMoleculeMask =unAlignedKymoMoleculeMask;

            
        else
            import OptMap.KymoAlignment.NRAlign.nralign;

            parfor i=1:length(hcaSessionStruct.unalignedKymos)
                alignedKymo{i} = nralign(double(unalignedKymos{i}));
            end
            hcaSessionStruct.alignedKymo = alignedKymo;
        end
    end
    timePassed = toc;
    disp(strcat(['All kymos were aligned in ' num2str(timePassed) ' seconds']));

end

