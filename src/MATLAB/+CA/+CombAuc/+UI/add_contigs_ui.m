function [lmTheory,cache] = add_contigs_ui(tsCA, hPanelContigImport, cache)
  % launch_contig_import_ui

    if nargin < 3
        cache = containers.Map();
        cache('caSessionStruct') = {};
    end
        
    %selectedItems
    
    import Fancy.UI.FancyList.FancyListMgr;
    lmTheory = FancyListMgr();
    lmTheory.set_ui_parent(hPanelContigImport);
    lmTheory.make_ui_items_listbox();
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(make_add_sequences(tsCA));
    flmbs1.add_button(make_remove_sequences());
    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 2;


    flmbs2.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());

    lmTheory.add_button_sets(flmbs1,flmbs2);

    % add barcodes
    function [btnAddKymos] =make_add_sequences(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Add contig(s)', ...
            @(~, ~, lmTheory) on_add_consensus_directly(lmTheory, ts));
        
        
        function [] = on_add_consensus_directly(lmTheory, ts)
            [barcodeFilenames, barcodeFilenamesDirpath] = uigetfile(...
                {'*.fasta;'}, ...
                'Select contig(s) to import', ...
                pwd, ...
                'MultiSelect','on');
        

            barcodeNames = strcat(barcodeFilenamesDirpath,barcodeFilenames);
            
            if ~iscell(barcodeNames)
                barcodeNames = {barcodeNames};
                barcodeInd = {[]};
            else
                barcodeInd =cell(1,size(barcodeNames,2));
            end
                
            lmTheory.add_list_items(barcodeNames, barcodeInd);
                    
        end
    end
   


    function [btnRemoveConsensus] = make_remove_sequences()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnRemoveConsensus = FancyListMgrBtn(...
            'Remove selected barcode(s)', ...
            @(~, ~, lm) on_remove_selected_consensus(lm));
        function [] = on_remove_selected_consensus(lm)
            lm.remove_selected_items();
        end
    end

end