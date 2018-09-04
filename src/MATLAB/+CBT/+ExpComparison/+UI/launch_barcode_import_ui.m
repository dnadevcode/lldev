function [lm] = launch_barcode_import_ui(hPanelBarcode, tsETE)
    % launch_barcode_import_ui

    import Fancy.UI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(hPanelBarcode);
    lm.make_ui_items_listbox();
    
    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 3;
    flmbs1.add_button(FancyListMgr.make_select_all_button_template());
    flmbs1.add_button(FancyListMgr.make_deselect_all_button_template());
    flmbs1.add_button(make_add_barcodes_btn(tsETE));

    
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;
    flmbs2.add_button(make_remove_barcodes_btn());
    
    lm.add_button_sets(flmbs1, flmbs2);
    
    function [btnAddBarcodes] = make_add_barcodes_btn(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddBarcodes = FancyListMgrBtn(...
            'Add barcodes', ...
            @(~, ~, lm) on_make_add_barcodes_btn(lm, ts));
        
        function [] = on_make_add_barcodes_btn(lm, ts)

            import OptMap.DataImport.prompt_and_read_consensus_outputs;
            fprintf('Started ETE similarity analysis with many barcodes\n')

            %---User input---
            % Barcodes selection
            promptTitle = 'Select Consensus Files For Comparison';
            [consensusBarcodeNames, stretchedConsensusBarcodes,stretchedConsensusBitmasks, ~] = prompt_and_read_consensus_outputs(promptTitle);

            if isempty(stretchedConsensusBarcodes) % Stops the function if no barcodes were selected
                fprintf('No consensus data was provided\n');
                return;
            end
    
            barStruct = cell(1,length(stretchedConsensusBarcodes));
            for i=1:length(stretchedConsensusBarcodes)
                barStruct{i}.stretchedConsensusBarcodes = stretchedConsensusBarcodes{i};
                barStruct{i}.stretchedConsensusBitmasks = stretchedConsensusBitmasks{i};
            end

            
            lm.add_list_items(consensusBarcodeNames, barStruct);
        end
    end
    


    function [btnRemoveBarcodes] = make_remove_barcodes_btn()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnRemoveBarcodes = FancyListMgrBtn(...
            'Remove selected barcode', ...
            @(~, ~, lm) on_make_remove_barcodes_btn(lm));
        function [] = on_make_remove_barcodes_btn(lm)
            lm.remove_selected_items();
        end
    end
end