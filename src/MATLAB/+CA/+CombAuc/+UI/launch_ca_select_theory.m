function [lmConsensus, tsCA,cache] = launch_ca_select_theory(lmConsensus,tsCA,cache)
    if nargin < 3
        cache = containers.Map();
    end

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs4 = FancyListMgrBtnSet();
    flmbs4.NUM_BUTTON_COLS = 1;
    
    flmbs4.add_button(launch_select_theory(tsCA));
    
    lmConsensus.add_button_sets(flmbs4);

    function [btnAddTh]=launch_select_theory(ts)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnAddTh = FancyListMgrBtn(...
            'Add theory sequence(s)', ...
            @(~, ~, lmConsensus) on_launch_select_theory_directly(lmConsensus, ts));
        
 		function [] = on_launch_select_theory_directly(lmConsensus, ts)
            
            tabTitle = 'Theory';

            [hTabTheoryImport, tabNumTheoryImport] = tsCA.create_tab(tabTitle);
            hPanelTheoryImport = uipanel(hTabTheoryImport);
            tsCA.select_tab(tabNumTheoryImport);
            
               
            % and save back to cache so that it can be accessed later
            cache('caSessionStruct') = caSessionStruct;
            
            import CA.CombAuc.UI.add_theory_ui;
            [lm,cache] = add_theory_ui(tsCA,hPanelTheoryImport, cache);   
         
            
            
            %[selectedItems, ~] = get_selected_list_items(lmConsensus);

            import CA.UI.launch_theory_import_ui;
            lm = launch_theory_import_ui(ts,selectedItems);
        end
    end

end