function [cache] = compare_experimental_barcodes_to_theory(lmTheory, cache)
  % launch_contig_import_ui

    if nargin < 2
        cache = containers.Map();
        cache('caSessionStruct') = {};
    end
        
  
    import Fancy.UI.FancyList.FancyListMgrBtnSet;

    flmbs4 = FancyListMgrBtnSet();
    flmbs4.NUM_BUTTON_COLS = 1;
    
    flmbs4.add_button(compare_exp_to_theory());

    lmTheory.add_button_sets(flmbs4);



    function [btnAddKymos] =compare_exp_to_theory()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddKymos = FancyListMgrBtn(...
            'Place contigs on the consensus barcode', ...
            @(~, ~, lm) on_compare_exp_to_theory(lm));
        
 		function [] = on_compare_exp_to_theory(lm)
            caSessionStruct = cache('caSessionStruct');
            
            import CA.CombAuc.UI.compare_to_theory_ui;
            caSessionStruct = compare_to_theory_ui(caSessionStruct);

        end

    end


end