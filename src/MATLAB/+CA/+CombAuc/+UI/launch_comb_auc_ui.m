function [lmConsensus, tsCA] = launch_comb_auc_ui(tsCA)
    % launch_comb_auc_ui -
    %  

    % title
    tabTitle = 'Consensus import';

    % create a tab for importing consensus
    hTabConsensusImport = tsCA.create_tab(tabTitle);
    hPanelConsensusImport = uipanel(hTabConsensusImport);
    tsCA.select_tab(hTabConsensusImport);

    
    import Fancy.UI.FancyList.FancyListMgr;
    lmConsensus = FancyListMgr();
    lmConsensus.set_ui_parent(hPanelConsensusImport);
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
   
    import Fancy.UI.FancyList.FancyListMgrBtnSet;    
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    flmbs3.add_button(launch_select_contigs(tsCA));
    lmConsensus.add_button_sets(flmbs3);



    flmbs4 = FancyListMgrBtnSet();
    flmbs4.NUM_BUTTON_COLS = 1;
    
    flmbs4.add_button(launch_select_theory(tsCA));

 
    
    lmConsensus.add_button_sets(flmbs1,flmbs2,flmbs3,flmbs4);

   

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

            bar = load(barcodeNames);
            barcodeStructs = bar;
            lmConsensus.add_list_items({barcodeNames}, barcodeStructs);
%             import CA.UI.add_plot_tab;
%             add_plot_tab(ts,bar,barcodeFilenames) 
%             
        end
    end



    function [btnAddTh]=launch_select_theory(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddTh = FancyListMgrBtn(...
            'Add theory sequence(s)', ...
            @(~, ~, lmConsensus) on_launch_select_theory_directly(lmConsensus, ts));
        
 		function [] = on_launch_select_theory_directly(lmConsensus, ts)
            [selectedItems, selectedIndices] = get_selected_list_items(lmConsensus);

    
            import CA.UI.launch_theory_import_ui;
            lm = launch_theory_import_ui(ts,selectedItems);
        end

    end


    function [addContigs] =launch_select_contigs(tsCA)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        addContigs = FancyListMgrBtn(...
            'Add contig(s)', ...
            @(~, ~, lmConsensus) on_add_contigs_directly(lmConsensus, tsCA));

 		function [] = on_add_contigs_directly(lmConsensus, tsCA)
            import CA.CombAuc.UI.launch_contig_import_ui;
            [lm,tsCA] = launch_contig_import_ui(tsCA,lmConsensus);          
        end

%     lm
%     [selectedItems, selectedIndices] = get_selected_list_items(lm);
%     selectedItems
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