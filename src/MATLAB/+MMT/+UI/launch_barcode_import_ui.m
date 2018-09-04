function [lm] = launch_barcode_import_ui(tsMM)
    %   adds a tab with list management UI/functionality  for
    %   experimental barcodes

    import MMT.Core.Settings.settings;
    sets = settings(); % 
      
%     
    tabTitle = 'Experimental barcodes';

    % create and select tab
    hTabKymoImport = tsMM.create_tab(tabTitle);
    hPanelKymoImport = uipanel(hTabKymoImport);
    tsMM.select_tab(hTabKymoImport);

    % create a list so that we can see the names
    import Fancy.UI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(hPanelKymoImport);
    lm.make_ui_items_listbox();
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
       
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(make_add_experimental_barcodes(tsMM));
    flmbs1.add_button(make_remove_consensus_btn());

    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 2;
    flmbs2.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());

    
    % make button for comparint experiments to theory
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    flmbs3.add_button(compare_experimental_barcodes_to_theory(tsMM));
    
    function [btnAddKymos] =make_add_experimental_barcodes(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Add experimental barcode(s)', ...
            @(~, ~, lm) on_add_barcodes_directly(lm, ts));
        
        function [] = on_add_barcodes_directly(lm, ts)
            [barcodeFilenames, barcodeFilenamesDirpath] = uigetfile(...
                {'*.mat;'}, ...
                'Select experimental barcode(s) to import', ...
                pwd, ...
                'MultiSelect','on');
            
            bar = load(strcat(barcodeFilenamesDirpath,barcodeFilenames));
            
            %figure,plot(bar.clusterConsensusData.barcode)
            
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
            barcodeNames = {strcat(barcodeFilenamesDirpath,barcodeFilenames)};
            barcodeStructs = {bar};
            lm.add_list_items(barcodeNames, barcodeStructs);
             
%             import MMT.GUI.launch_theory_ui;
%             lm = launch_theory_ui(tsCBC);
            end
    end
   

    function [btnAddKymos] =compare_experimental_barcodes_to_theory(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Select theory sequence(s)', ...
            @(~, ~, lm) on_select_theory_sequences(lm, ts));
        

 		function [] = on_select_theory_sequences(lm, ts)
            [selectedItems, selectedIndices] = get_selected_list_items(lm);
            
            import MMT.UI.launch_theory_ui;
            lm = launch_theory_ui(tsMM,selectedItems,sets);
        end
       
    end

    lm.add_button_sets(flmbs1,flmbs2,flmbs3);

  function [btnRemoveConsensus] = make_remove_consensus_btn()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnRemoveConsensus = FancyListMgrBtn(...
            'Remove selected barcode(s)', ...
            @(~, ~, lm) on_remove_selected_consensus(lm));
        function [] = on_remove_selected_consensus(lm)
            lm.remove_selected_items();
        end
    end
end