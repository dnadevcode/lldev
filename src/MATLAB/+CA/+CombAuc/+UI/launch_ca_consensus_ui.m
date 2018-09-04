function [lmConsensus, tsCA] = launch_ca_consensus_ui(hPanelCA,tsCA)
    % launch_ca_consensus_ui
    
    import Fancy.UI.FancyList.FancyListMgr;
    lmConsensus = FancyListMgr();
    lmConsensus.set_ui_parent(hPanelCA);
    lmConsensus.make_ui_items_listbox();
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(make_add_consensus_barcodes(tsCA));
    flmbs1.add_button(make_remove_consensus_btn());
    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 2;

    flmbs2.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());
    
    lmConsensus.add_button_sets(flmbs1,flmbs2);


    % add barcodes
    function [btnAddKymos] =make_add_consensus_barcodes(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Add consensus barcode(s)', ...
            @(~, ~, lmConsensus) on_add_consensus_directly(lmConsensus, ts));
        
        function [] = on_add_consensus_directly(lmConsensus, ts)
            [barcodeFilenames, barcodeFilenamesDirpath] = uigetfile(...
                {'*.mat;'}, ...
                'Select consensus barcode(s) to import', ...
                pwd, ...
                'MultiSelect','on');
        
            barcodeNames = strcat(barcodeFilenamesDirpath,barcodeFilenames);
            
            if ~iscell(barcodeNames)
                barcodeNames = {barcodeNames};
                barcodeInd = {[]};
            else
                barcodeInd =cell(1,size(barcodeNames,2));
            end
                
            lmConsensus.add_list_items(barcodeNames, barcodeInd);
        end
    end

    function [btnRemoveConsensus] = make_remove_consensus_btn()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnRemoveConsensus = FancyListMgrBtn(...
            'Remove selected barcode(s)', ...
            @(~, ~, lmConsensus) on_remove_selected_consensus(lmConsensus));
        function [] = on_remove_selected_consensus(lmConsensus)
            lmConsensus.remove_selected_items();
        end
    end

end