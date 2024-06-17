function []= CBT_to_ETE_conversion()
   % quick fix to save CBT theory as ETE compatible input.
   
    hFig = figure(...
        'Name', 'CBT to ETE conversion scriptn', ...
        'Units', 'normalized', ...
        'OuterPosition', [0 0 1 1], ...
        'NumberTitle', 'off', ...
        'MenuBar', 'none' ...
    );
    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);

	import CBT.TheoryComparison.UI.get_parameters_ui;
	get_parameters_ui(ts, @g_par);
    function settingsStruct= g_par(paramsStruct )
         settingsStruct.constants = paramsStruct;
         on_theory_load_end(settingsStruct)
    end
% 
    function on_theory_load_end(settingsStruct)
        [file,place] = uigetfile({'*.fasta'},'Select fasta file');
        theorySequence = fastaread(strcat(place,file));
        concNetropsin_molar = settingsStruct.constants.NETROPSINconc;
        concYOYO1_molar = settingsStruct.constants.YOYO1conc;
        bindingSequence = settingsStruct.constants.bindingSequence;
        [file,path] = uiputfile('*.mat','Save CBT file As ETE loadable file',strcat(file,'.mat'));

        for i=1:length(theorySequence)
            import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
            theoryCurve_bpRes_prePSF = cb_netropsin_vs_yoyo1_plasmid(theorySequence(i).Sequence, concNetropsin_molar, concYOYO1_molar, [], true);

            if ~isequal(bindingSequence,' ')
                import ELT.Core.find_sequence_matches;
                [bindingExpectedMask, ~] = find_sequence_matches(bindingSequence, theorySequence(i).Sequence);
            else
                bindingExpectedMask = [];
            end
        
            import Fancy.Utils.extract_fields;
            [...
                deltaCut,...
                psfSigmaWidth_nm,...
                psfSigmaWidth_bp,...
                pixelWidth_nm,...
                meanBpExt_pixels...
            ] = extract_fields(settingsStruct.constants, {
                'deltaCut',...
                'psfWidth_nm',...
                'psfWidth_bp',...
                'nmPerPixel',...
                'pixelsPerBp'...
                });

            import Microscopy.Simulate.Core.apply_point_spread_function;
            theoryCurveB_bpRes = apply_point_spread_function(theoryCurve_bpRes_prePSF, psfSigmaWidth_bp);

            import CBT.Core.convert_bpRes_to_pxRes;
            theoryCurveB_pxRes = convert_bpRes_to_pxRes(theoryCurveB_bpRes, meanBpExt_pixels);

            theoryCurveB_pxRes = zscore(theoryCurveB_pxRes);

            import CBT.TheoryComparison.Core.get_theory_bitmask;
            theoryCurveBitmaskB = get_theory_bitmask(theoryCurveB_pxRes, 1, deltaCut, psfSigmaWidth_nm, pixelWidth_nm); % get bitmask as if experiment


            clusterConsensusData.barcode = theoryCurveB_pxRes;
            clusterConsensusData.bitmask = theoryCurveBitmaskB;
            clusterConsensusData.datetime = datetime;
            clusterConsensusData.settings = settingsStruct;

            if ~isequal(bindingSequence,' ')
                theoryCurveB_bpRes = apply_point_spread_function(bindingExpectedMask, psfSigmaWidth_bp);
                theoryCurveB_pxRes = convert_bpRes_to_pxRes(theoryCurveB_bpRes, meanBpExt_pixels);
                theoryCurveB_pxRes = zscore(theoryCurveB_pxRes);
                clusterConsensusData.bindingBarcode = theoryCurveB_pxRes;
            end
            save(strcat(path,file),'clusterConsensusData','-v7.3')
        end
    end


end
% 
% import CBT.TheoryComparison.UI.on_;
% get_parameters_ui(ts, @on_params_ready);
% 
% 
% import CBT.Import.Helpers.read_CBT_settings_struct;
% cbtSettingsStruct = read_CBT_settings_struct();
% 
% 
% %---User input---
% % Barcodes selection
% promptTitle = 'Select Consensus Files For Comparison';
% [consensusBarcodeNames, stretchedConsensusBarcodes,stretchedConsensusBitmasks, ~] = prompt_and_read_consensus_outputs(promptTitle);
