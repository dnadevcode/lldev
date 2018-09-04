function [lm] = launch_theory_ui(tsMM,expBarcodes,sets)
    % launch_theory_ui -
    %   adds a tab with list management UI/functionality 
    %    
    
    % load settings.
%     import MMT.Core.Settings.settings;
%     sets = settings(); % 

            
    barcodeStr = load(expBarcodes{1});
    
    bar = barcodeStr.clusterConsensusData.barcode;

    % in case it's not zscored, and settings say that we should zscore, we zscore the barcode here
    if sets.promtToZscore==1 %
        bar = zscore(bar);
    end

	tabTitle = 'Theory';
    [hTabTheoryImport] = tsMM.create_tab(tabTitle);
    hPanelTheoryImport = uipanel(hTabTheoryImport);
    tsMM.select_tab(hTabTheoryImport);

	import Fancy.UI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(hPanelTheoryImport);
    lm.make_ui_items_listbox();
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(make_add_sequences(tsMM));
    flmbs1.add_button(make_remove_consensus_btn());
    
    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 2;
	flmbs2.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());

    flmbs3 = FancyListMgrBtnSet();

    flmbs3.NUM_BUTTON_COLS = 1;

    flmbs3.add_button(create_ps_barcode(tsMM));
    %different model as well

    %flmbs1.add_button(make_add_experimental_barcodes(tsCBC));
       % add barcodes
    function [btnAddKymos] =make_add_sequences(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Add sequence(s)', ...
            @(~, ~, lm) on_add_sequences_directly(lm, ts));
        
        
        function [] = on_add_sequences_directly(lm, ts)
            [barcodeFilenames, barcodeFilenamesDirpath] = uigetfile(...
                {'*.fasta;'}, ...
                'Select sequence(s) to import', ...
                pwd, ...
                'MultiSelect','on');
        
            FASTAData = fastaread(strcat(barcodeFilenamesDirpath,barcodeFilenames));
            
            numFiles = size(FASTAData,1);

            theoreticalSequence = cell(1,size(FASTAData,1));
            nameSequence = cell(1,size(FASTAData,1));
            for i=1:numFiles
                theoreticalSequence{i} =  FASTAData(i).Sequence;
                nameSequence{i} = FASTAData(i).Header;
            end

            lm.add_list_items(nameSequence, theoreticalSequence);
            end
    end
%     
%     
%     function [btnCreatePS]= create_pb_barcode(ts)
%          % Peyrard-Bishop model
%          import FancyGUI.FancyList.FancyListMgrBtn;
%          btnCreatePS = FancyListMgrBtn(...
%             'PB model', ...
%             @(~, ~, lm) createPB(lm, ts));  
%              
%          function [] = createPB(lm, ts)
%             askForParams = 0;
% 
%             if askForParams==1 
% 
%                 import MMT.Import.prompt_meltmap_params_PB;
%                 [paramsAreValid, temperature_Kelvin, bc, gamma] = prompt_meltmap_params_PB();
%                 if not(paramsAreValid)
%                     return;
%                 end
% 
%             else
%                 temperature_Kelvin = 273.15+43;
%                 gamma = -0.042;
%                 bc = 'closed';
%             end
%             DNA_melt_preferences;
% 
%                         
%             [selectedItems, selectedIndices] = get_selected_list_items(lm);
%             theorySequence = selectedItems{2};
% 
%              pl = nt2int(theorySequence);
% 
%             
%              vec = 1-melt_prob_long(temperature_Kelvin,gamma,pl, 100000, 1000,bc);
%     
%             import Zeromodel.gaussian_kernel;
%             kbpPerPixel = length(vec)/length(bar);
% 
%             ker = gaussian_kernel(length(vec),2.95*psfSigmaWidth);
%             barcodeBpRes= ifft(fft(vec).*conj(fft(transpose(ker)))); 
%             barcodePxRes = interp1([1:length(barcodeBpRes)], barcodeBpRes,linspace(1,length(barcodeBpRes),length(barcodeBpRes)/(kbpPerPixel)));
%             
%             import MMT.UI.add_plot_tab_pb;
%             add_plot_tab_pb(ts,bar,barcodePxRes,kbpPerPixel) 
%         
%     
%          end
%          
% 
%         
%     end

    
    function [btnCreatePS]= create_ps_barcode(ts)
         import Fancy.UI.FancyList.FancyListMgrBtn;
         btnCreatePS = FancyListMgrBtn(...
            'PS model', ...
            @(~, ~, lm) createPS(lm, ts));  
        
         function [] = createPS(lm, ts)
            askForParams = 0;
            
            if askForParams==1 
                import MMT.Import.prompt_meltmap_params_PS;
                [paramsAreValid, temperature_Celsius, saltConc_Molar] = prompt_meltmap_params_PS(sets.saltConc, sets.temp);
                if not(paramsAreValid)
                    return;
                end
            else
                temperature_Celsius = sets.temp;%82
                saltConc_Molar = sets.saltConc;
            end
            
            [selectedItems, selectedIndices] = get_selected_list_items(lm);
            
            theorySequence = selectedItems{2};
            
            % very basic implementation of melting maps theory!
            import MMT.Core.calculate_nonmelting_probs;
            vec = calculate_nonmelting_probs(theorySequence, temperature_Celsius, saltConc_Molar); 
            import MMT.Zeromodel.gaussian_kernel;
    
            ker = gaussian_kernel(length(vec),sets.psfSigmaWidth_nm/sets.nmPerBps); % include local stretching, which at the moment is assumed to be uniformal..
            barcodeBpRes= ifft(fft(vec).*conj(fft(transpose(ker)))); 
            barcodePxRes = interp1([1:length(barcodeBpRes)], barcodeBpRes,linspace(1,length(barcodeBpRes),length(barcodeBpRes)/(sets.pixelWidth_nm/sets.nmPerBps)));
            
            % convert the experiment to the same length as theory
            import CBT.Consensus.Core.convert_barcodes_to_common_length;
            [barcodes] = convert_barcodes_to_common_length({bar}, length(barcodePxRes));
            stretchFactor = length(bar)/length(barcodePxRes);

            
            import CBT.Consensus.Core.calc_best_synced_orientation_similarity;
            bsosStruct = calc_best_synced_orientation_similarity(barcodes{1}, barcodePxRes, ones(1,length(barcodePxRes)),ones(1,length(barcodePxRes)));

 
            import MMT.UI.add_plot_tab;
            add_plot_tab(ts,barcodes,barcodePxRes,bsosStruct,sets) 


            mmtSessionStruct = struct();
            mmtSessionStruct.bitweight = ones(1,length(barcodes{1})); % fix to include bitweights.
            mmtSessionStruct.stats = bsosStruct;
            mmtSessionStruct.original = bar;
            mmtSessionStruct.barcode = barcodes{1};
            mmtSessionStruct.theoryBarcode = barcodePxRes;
            mmtSessionStruct.stretchFactor = length(bar)/length(barcodePxRes);
            mmtSessionStruct.timestamp = datetime;
            mmtSessionStruct.settings = sets;
         
      
     
            import MMT.UI.launch_export_ui;
            launch_export_ui(ts, {'Melting map session files'}, mmtSessionStruct)

         end


    end

    
    function [btnAddKymos] =make_add_experimental_barcodes(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'PS model', ...
            @(~, ~, lm) on_add_barcodes_directly(lm, ts));
        
        
        function [] = on_add_barcodes_directly(lm, ts)

           % import OldDBM.General.Import.import_raw_kymos;
           % [rawKymos, rawKymoFilepaths] = import_raw_kymos();

            [barcodeFilenames, barcodeFilenamesDirpath] = uigetfile(...
                {'*.mat;'}, ...
                'Select experimental barcode(s) to import', ...
                pwd, ...
                'MultiSelect','on');
    
       
            barcodeNames = {barcodeFilenames};
            barcodeStructs = {barcodeFilenames};
            lm.add_list_items(barcodeNames, barcodeStructs);
        end
    end
   
    %   flmbs1.add_button(make_add_kymos_directly_btn(tsCBC));

    lm.add_button_sets(flmbs1,flmbs2,flmbs3);

    function [btnRemoveConsensus] = make_remove_consensus_btn()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnRemoveConsensus = FancyListMgrBtn(...
            'Remove selected sequence(s)', ...
            @(~, ~, lm) on_remove_selected_consensus(lm));
        function [] = on_remove_selected_consensus(lm)
            lm.remove_selected_items();
        end
    end

end