function [lm] = launch_theory_import_ui(tsCA, selectedItems)
    % launch_kymo_import_ui -
    %   adds a tab with list management UI/functionality  for
    %    kymographs
     
    % change into "load settings" or something..
    
%     
%     import MMT.Core.Settings.settings;
%     sets = settings(); % 
%             
%     psfSigmaWidth =  1115.7;
%     kbpPerPixel = 592.1;
%     askForParams = 0;
%     
    
%     
%     tabTitle = sprintf('MMT vs E');
%     hTab =  tsMM.create_tab(tabTitle);
%     tsMM.select_tab(hTab);
%     
%     
%     hPanel = uipanel('Parent', hTab, 'Units', 'normalized', 'Position', [0 0 1 1]);
% 
%     import FancyGUI.FancyTabs.TabbedScreen;
%     tsInner = TabbedScreen(hPanel);
% 
%     tabTitle = sprintf('Theory');
%     hTab =  tsMM.create_tab(tabTitle);
%     tsMM.select_tab(hTab);
%     hPanel = uipanel('Parent', hTab, 'Units', 'normalized', 'Position', [0 0 1 1]);
% 
%     import FancyGUI.FancyTabs.TabbedScreen;
%     tsInner = TabbedScreen(hPanel);
% 
%     
    bar = load(selectedItems{1});
 %   bar
%     bar = bar.clusterConsensusData.barcode;
   % tsMM.add_list_items('theory', bar);
%     import MMT.UI.add_individual_plot_tabs;
%     add_individual_plot_tabs(tsInner, {bar}, 0,0);
% 

	tabTitle = 'Theory';

    [hTabTheoryImport, tabNumTheoryImport] = tsCA.create_tab(tabTitle);
    hPanelTheoryImport = uipanel(hTabTheoryImport);
    tsCA.select_tab(tabNumTheoryImport);

	import FancyGUI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(hPanelTheoryImport);
    lm.make_ui_items_listbox();
    
    import FancyGUI.FancyList.FancyListMgrBtnSet;
    
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(make_add_sequences(tsCA));
    flmbs1.add_button(make_remove_consensus_btn());
    
    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 2;
	flmbs2.add_button(FancyListMgr.make_select_all_button_template());

%    flmbs1.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());

    flmbs3 = FancyListMgrBtnSet();

    flmbs3.NUM_BUTTON_COLS = 1;

    flmbs3.add_button(determine_thresh(tsCA));
%     flmbs3.add_button(create_pb_barcode(tsMM));

    %flmbs1.add_button(make_add_experimental_barcodes(tsCBC));
       % add barcodes
    function [btnAddKymos] =make_add_sequences(ts)
        import FancyGUI.FancyList.FancyListMgrBtn;
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
%              
            
%             import FancyGUI.FancyTabs.TabbedScreen;
%             tsInner = TabbedScreen(hPanel);
%     
%             import MMT.UI.add_individual_plot_tabs;
%             add_individual_plot_tabs(tsInner, {barcodePxRes}, temperature_Kelvin, gamma);
%             
%             import MMT.GUI.launch_theory_ui;
%             lm = launch_theory_ui(tsCBC);
            end
    end
    
    
    function [btnCreatePS]= determine_thresh(ts)
         import FancyGUI.FancyList.FancyListMgrBtn;
         btnCreatePS = FancyListMgrBtn(...
            'Determine T-E thresh', ...
            @(~, ~, lm) det_thresh(lm, ts));  
        
             function [] = det_thresh(lm, ts)
                 [selectedItems, selectedIndices] = get_selected_list_items(lm);
                 theorySequence = selectedItems{2};
                 
%                 [barcodeFilenames, barcodeFilenamesDirpath] = uigetfile(...
%                 {'*.mat;'}, ...
%                 'Select meanFFT', ...
%                 pwd, ...
%                 'MultiSelect','off');
%                 meanFFT = load(strcat(barcodeFilenamesDirpath,barcodeFilenames));
            

   
                m = load('meanF.mat');
                meanFFT = interp1(m.meanFFT,linspace(1,length(m.meanFFT),m.len));
    
    
                import CA.CombAuc.Core.Settings.settings_thresh;
                settings = settings_thresh(); 

                import CA.CombAuc.Core.run_thresh;
               % size(meanFFT.meanFFTest)
                
                [placedTot,placedCor,settings] = run_thresh(theorySequence, bar.barcode, meanFFT.meanFFTest,settings);
                 
                import CA.CombAuc.UI.add_plot_thresh_tab;
                add_plot_thresh_tab(ts,placedTot,placedCor,settings.contigSizeAllPos,settings.lengthBarcode, settings.kbpPerPixel,'Threshold plot') 
                 
             end
%             askForParams = 1;
%             
%             if askForParams==1 
% 
%                 import MMT.Import.prompt_meltmap_params_PS;
%                 [paramsAreValid, temperature_Celsius, saltConc_Molar] = prompt_meltmap_params_PS();
%                 if not(paramsAreValid)
%                     return;
%                 end
% 
%             else
%                 temperature_Celsius = 83;%82
%                 saltConc_Molar = 0.05;
%             end
%             
%             [selectedItems, selectedIndices] = get_selected_list_items(lm);
%             
%             theorySequence = selectedItems{2};
% %             [theoryName, theorySequenceDirpath] = uigetfile(...
% %                 {'*.mat', '.mat files'; '*.fasta','.fasta files';}, ...
% %                 'Select experimental barcode(s) to import', ...
% %                 pwd, ...
% %                 'MultiSelect','on');
% %             if (isequal(theoryName(end-4:end),'fasta'))
% %                 theorySequence = fastaread(strcat(theorySequenceDirpath,theoryName));
% %             else
% %                 theorySequence = load(strcat(theorySequenceDirpath,theoryName));
% %             end
%             
%             %theorySequence
%             
%             % very basic implementation of melting maps theory!
%             import MMT.Core.calculate_nonmelting_probs;
%             vec = calculate_nonmelting_probs(theorySequence, temperature_Celsius, saltConc_Molar); 
%             import Zeromodel.gaussian_kernel;
%             kbpPerPixel = length(vec)/length(bar);
%             %kbpPerPixel
%             ker = gaussian_kernel(length(vec),2.95*psfSigmaWidth); % include local stretching, which at the moment is assumed to be uniformal..
%             barcodeBpRes= ifft(fft(vec).*conj(fft(transpose(ker)))); 
%             barcodePxRes = interp1([1:length(barcodeBpRes)], barcodeBpRes,linspace(1,length(barcodeBpRes),length(barcodeBpRes)/(kbpPerPixel)));
%             
%             
%             import MMT.UI.add_plot_tab;
%             
%             add_plot_tab(ts,bar,barcodePxRes,kbpPerPixel) 
%             
            
      
    

            
%             tabTitle = sprintf('(%s) Melting map theory results', 'Poland-Schegara ');
%             hTab =  ts.create_tab(tabTitle);
%             ts.select_tab(hTab);
%             hPanel = uipanel('Parent', hTab, 'Units', 'normalized', 'Position', [0 0 1 1]);
% 
%             import FancyGUI.FancyTabs.TabbedScreen;
%             tsInner = TabbedScreen(hPanel);
%     
%             import MMT.UI.add_individual_plot_tabs;
%             add_individual_plot_tabs(tsInner, {barcodePxRes}, temperature_Celsius, saltConc_Molar);
%     
    


    end

    
    function [btnAddKymos] =make_add_experimental_barcodes(ts)
        import FancyGUI.FancyList.FancyListMgrBtn;
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
    
            barcodeFilenames
%             import OldDBM.General.Import.prompt_files_bps_per_pixel_wrapper;
%             [pixelsWidths_bps] = prompt_files_bps_per_pixel_wrapper(rawKymoFilepaths);

            % todo: generate kymo structs directly instead of using data
            %  wrapper
            
%             import OldDBM.General.DataWrapper;
%             dbmODW = DataWrapper();
%             
%             import OldDBM.General.Import.set_raw_kymos_and_bps_per_pixel;
%             set_raw_kymos_and_bps_per_pixel(dbmODW, rawKymos, rawKymoFilepaths, pixelsWidths_bps);
%             
%             import OldDBM.General.Export.extract_kymo_structs;
%             kymoStructs = extract_kymo_structs(dbmODW);
%             
%             
%             unalignedKymos = cellfun(...
%                 @(kymoStruct) kymoStruct.unalignedKymo, ...
%                 kymoStructs, ...
%                 'UniformOutput', false);
%             kymoNames = cellfun(...
%                 @(kymoStruct) kymoStruct.displayName, ...
%                 kymoStructs, ...
%                 'UniformOutput', false);
%             
%             hTabUnalignedKymos = get_unaligned_kymos_tab(ts);
%             hPanelUnalignedKymos = uipanel('Parent', hTabUnalignedKymos);
%             delete(allchild(hPanelUnalignedKymos));
%             import OldDBM.Kymo.UI.show_kymos_in_grid;
%             show_kymos_in_grid(hPanelUnalignedKymos, unalignedKymos, kymoNames);
% 
            barcodeNames = {barcodeFilenames};
            barcodeStructs = {barcodeFilenames};
            lm.add_list_items(barcodeNames, barcodeStructs);
        end
    end
   
    %   flmbs1.add_button(make_add_kymos_directly_btn(tsCBC));

    lm.add_button_sets(flmbs1,flmbs2,flmbs3);
%     
%     function [btnAddKymos] = make_add_kymos_directly_btn(ts)
%         import FancyGUI.FancyList.FancyListMgrBtn;
%         btnAddKymos = FancyListMgrBtn(...
%             'Add kymographs directly', ...
%             @(~, ~, lm) on_add_kymos_directly(lm, ts));
%         
%         
%         function [] = on_add_kymos_directly(lm, ts)
% 
%             import OldDBM.General.Import.import_raw_kymos;
%             [rawKymos, rawKymoFilepaths] = import_raw_kymos();
% 
%             import OldDBM.General.Import.prompt_files_bps_per_pixel_wrapper;
%             [pixelsWidths_bps] = prompt_files_bps_per_pixel_wrapper(rawKymoFilepaths);
% 
%             % todo: generate kymo structs directly instead of using data
%             %  wrapper
%             
%             import OldDBM.General.DataWrapper;
%             dbmODW = DataWrapper();
%             
%             import OldDBM.General.Import.set_raw_kymos_and_bps_per_pixel;
%             set_raw_kymos_and_bps_per_pixel(dbmODW, rawKymos, rawKymoFilepaths, pixelsWidths_bps);
%             
%             import OldDBM.General.Export.extract_kymo_structs;
%             kymoStructs = extract_kymo_structs(dbmODW);
%             
%             
%             unalignedKymos = cellfun(...
%                 @(kymoStruct) kymoStruct.unalignedKymo, ...
%                 kymoStructs, ...
%                 'UniformOutput', false);
%             kymoNames = cellfun(...
%                 @(kymoStruct) kymoStruct.displayName, ...
%                 kymoStructs, ...
%                 'UniformOutput', false);
%             
%             hTabUnalignedKymos = get_unaligned_kymos_tab(ts);
%             hPanelUnalignedKymos = uipanel('Parent', hTabUnalignedKymos);
%             delete(allchild(hPanelUnalignedKymos));
%             import OldDBM.Kymo.UI.show_kymos_in_grid;
%             show_kymos_in_grid(hPanelUnalignedKymos, unalignedKymos, kymoNames);
% 
%             lm.add_list_items(kymoNames, kymoStructs);
%         end
%     end
%     
%     
%     function [btnAddKymos] = make_add_kymos_from_dbm_btn(ts)
%         import FancyGUI.FancyList.FancyListMgrBtn;
%         btnAddKymos = FancyListMgrBtn(...
%             'Add kymographs from  DBM sessions', ...
%             @(~, ~, lm) on_add_kymos_from_dbm(lm, ts));
% 
%         function [aborted, kymoNames, kymoStructs] = prompt_kymos_from_DBM_session()
%             % prompt_kymos_from_DBM_session - get kymo structs
%             %   extracted from formatted DBM session .mat files provided
%             %   by a prompt to the user
% 
%             import CBT.Consensus.Import.prompt_dbm_session_filepath;
%             [aborted, sessionFilepath] = prompt_dbm_session_filepath();
% 
%             if aborted
%                 kymoStructs = cell(0, 1);
%                 kymoNames = cell(0, 1);
%                 return;
%             end
% 
%             import OldDBM.General.Import.try_loading_from_session_file;
%             [dbmODW, dbmOSW] = try_loading_from_session_file(sessionFilepath);
%             
% 
%             import OldDBM.General.Export.DataExporter;
%             dbmDE = DataExporter(dbmODW, dbmOSW);
%             kymoStructs = dbmDE.extract_kymo_structs();
%             kymoNames = cellfun(...
%                 @(kymoStruct) kymoStruct.displayName, ...
%                 kymoStructs, ...
%                 'UniformOutput', false);
%             
%         end
%         function [] = on_add_kymos_from_dbm(lm, ts)
%             [aborted, kymoNames, kymoStructs] = prompt_kymos_from_DBM_session();
%             if aborted
%                 return;
%             end
%             
%             unalignedKymos = cellfun(...
%                 @(kymoStruct) kymoStruct.unalignedKymo, ...
%                 kymoStructs, ...
%                 'UniformOutput', false);
%             
%             hTabUnalignedKymos = get_unaligned_kymos_tab(ts);
%             hPanelUnalignedKymos = uipanel('Parent', hTabUnalignedKymos);
%             delete(allchild(hPanelUnalignedKymos));
%             import OldDBM.Kymo.UI.show_kymos_in_grid;
%             show_kymos_in_grid(hPanelUnalignedKymos, unalignedKymos, kymoNames);
% 
%             lm.add_list_items(kymoNames, kymoStructs);
%         end            
%     end
% 
%     function [hTabUnalignedKymos] = get_unaligned_kymos_tab(tsCBC)
%         persistent localhTabUnalignedKymos;
%         if isempty(localhTabUnalignedKymos) || not(isvalid(localhTabUnalignedKymos))
%             hTabUnalignedKymos = tsCBC.create_tab('Unaligned Kymos');
%             localhTabUnalignedKymos = hTabUnalignedKymos;
%         else
%             hTabUnalignedKymos = localhTabUnalignedKymos;
%         end
%     end
% 

    function [btnRemoveConsensus] = make_remove_consensus_btn()
        import FancyGUI.FancyList.FancyListMgrBtn;
        btnRemoveConsensus = FancyListMgrBtn(...
            'Remove selected sequence(s)', ...
            @(~, ~, lm) on_remove_selected_consensus(lm));
        function [] = on_remove_selected_consensus(lm)
            lm.remove_selected_items();
        end
    end

end