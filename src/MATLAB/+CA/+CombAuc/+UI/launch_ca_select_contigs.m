function [lmConsensus, tsCA,cache] = launch_ca_select_contigs(lmConsensus,tsCA,cache)
    if nargin < 3
        cache = containers.Map();
        cache('caSessionStruct') = {};
    end

    import Fancy.UI.FancyList.FancyListMgrBtnSet;    
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    flmbs3.add_button(launch_select_contigs(tsCA));
    lmConsensus.add_button_sets(flmbs3);


    function [addContigs] =launch_select_contigs(tsCA)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        addContigs = FancyListMgrBtn(...
            'Add contig(s)', ...
            @(~, ~, lmConsensus) on_add_contigs_directly(lmConsensus, tsCA));

 		function [] = on_add_contigs_directly(lmConsensus, tsCA)
            
            tabTitle = 'Contig import';

            % create a tab for importing consensus
            hTabContigImport = tsCA.create_tab(tabTitle);
            hPanelContigImport = uipanel(hTabContigImport);
            tsCA.select_tab(hTabContigImport);
    
            % get selected consensus files, since this tab is closing
            caSessionStruct = cache('caSessionStruct');
            [selectedItems, selectedIndices] = get_selected_list_items(lmConsensus);
            caSessionStruct.consensus = cellfun(@load,selectedItems(:,1),'UniformOutput',false);
            
            % and save back to cache so that it can be accessed later
            cache('caSessionStruct') = caSessionStruct;
            
            
            import CA.CombAuc.UI.add_contigs_ui;
            [lm,cache] = add_contigs_ui(tsCA,hPanelContigImport, cache);   
         
            import CA.CombAuc.UI.compute_contig_barcodes;
            [cache] = compute_contig_barcodes(lm, cache);    
            

            import CA.CombAuc.UI.compare_experimental_barcodes_to_theory;
            [cache] = compare_experimental_barcodes_to_theory(lm, cache);  
    
        end
    end


end