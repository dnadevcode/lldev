function [cache] = compute_contig_barcodes(lmTheory, cache)
  % launch_contig_import_ui

    if nargin < 2
        cache = containers.Map();
        cache('caSessionStruct') = {};
    end
        
    %selectedItems
  
    import Fancy.UI.FancyList.FancyListMgrBtnSet;

    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    flmbs3.add_button(compute_contig_barcodes(lmTheory));

    lmTheory.add_button_sets(flmbs3);

    function [btnAddKymos] = compute_contig_barcodes(lmTheory)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Compute contig barcodes', ...
            @(~, ~, lm) compute_directly(lmTheory));
        
 		function [] = compute_directly(lmTheory)
            [selectedItems, ~] = get_selected_list_items(lmTheory);
            
            caSessionStruct = cache('caSessionStruct');
            
            caSessionStruct.contigData  = cellfun(@(xx) fastaread(xx),selectedItems(:,1),'UniformOutput',false);
          
            import CA.UI.contig_barcodes_ui;
            [caSessionStruct] = contig_barcodes_ui(caSessionStruct);
            
            cache('caSessionStruct') = caSessionStruct;
        end

    end


end