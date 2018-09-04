function [cache] = make_consensus_structure( lm, ts, cache )
    % make_consensus_ssd

    if nargin < 3
        cache = containers.Map();
    end

    % set up buttons
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    
    flmbs3.add_button(make_cns(ts));

    lm.add_button_sets(flmbs3);
  
    function [btnGenerateConsensus] = make_cns(ts)
        function on_make_cns(lm, ts)
            
            % load structures from cache
            hcaSessionStruct = cache('hcaSessionStruct');
            sets = cache('sets');
         
            % choose alignment method
            if ~sets.skipAlignChoice
                alignChoice = questdlg('Choose alignment method', 'Two possible alignment methods', 'nralign', 'ssdalign (updated 24/11/17)',  'ssdalign (updated 24/11/17)');
                sets.alignMethod = ~strcmp(alignChoice,'nralign');
            end
            
            % kymo alignment
            import CBT.Hca.UI.align_kymos;
            hcaSessionStruct = align_kymos(sets,hcaSessionStruct);
          
            % this will store unfiltered barcode structure.
            hcaSessionStruct.barcodeGen = cell(length(hcaSessionStruct.unalignedKymos),1);
            
            % input parameters.
            if ~sets.skipDefaultConsensusSettings
                import CBT.Hca.Import.get_barcode_params;
                sets.barcodeConsensusSettings = get_barcode_params(sets.barcodeConsensusSettings);
            end

            % should we include filtered barcodes as well?
            if ~sets.skipFilterSettings
                sets.filterSettings.filter=1;
                sets.filterSettings.promptForfilterSettings = 1;
                titleText = 'Selection of number of timeframes for filtered kymographs';
                import CBT.Hca.Import.get_filter_settings;
                [sets.filterSettings] = get_filter_settings(sets.filterSettings,titleText);
            end
        
            % choose pre-stretching method
            if ~sets.skipPrechoice
                prestretchChoice = questdlg('Prestretch barcodes to the same lengths', 'Prestretching', 'yes (if multiple copies of one DNA molecule)', 'no', 'yes (if multiple copies of one DNA molecule)');
                sets.prestretchMethod = strcmp(prestretchChoice, 'yes (if multiple copies of one DNA molecule)');
            end
            
            % generate barcodes
            import CBT.Hca.UI.Helper.gen_barcodes;
            hcaSessionStruct = gen_barcodes(hcaSessionStruct,sets);
            sets.barcodeConsensusSettings.promptToConfirmTF = false;
                
            if ~sets.skipbarcodeConsensusSettings
                import CBT.Hca.UI.Helper.make_barcode_settings;
                [commonLength,aborted] = make_barcode_settings(hcaSessionStruct.lengths);
                sets.barcodeConsensusSettings.aborted = aborted;
                sets.barcodeConsensusSettings.commonLength = commonLength;
               % sets.barcodeConsensusSettings.barcodeClusterLimit = clusterScoreThresholdNormalized;
            end

            % generate consensus
            import CBT.Hca.UI.Helper.gen_consensus
            hcaSessionStruct = gen_consensus(hcaSessionStruct,sets);

            
            % select consensus
            import CBT.Hca.UI.Helper.select_consensus
            [hcaSessionStruct,sets] = select_consensus(hcaSessionStruct,sets);

            cache('hcaSessionStruct') = hcaSessionStruct;     
            cache('sets') = sets;            
        end

        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnGenerateConsensus = FancyListMgrBtn(...
            'Make consensus structure', ...
            @(~, ~, lm) on_make_cns(lm, ts));
    end
end

