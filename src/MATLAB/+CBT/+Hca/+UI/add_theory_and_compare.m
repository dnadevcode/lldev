function [cache] = add_theory_and_compare( lm, ts, cache )
    if nargin < 3
        cache = containers.Map();
    end

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs4 = FancyListMgrBtnSet();
    flmbs4.NUM_BUTTON_COLS = 1;
    flmbs4.add_button(make_theory(ts));
    lm.add_button_sets(flmbs4);

    function [btnOut] = make_theory(ts)
        
        function on_make_theory(lm, ts)
     
%             import CBT.Hca.UI.launch_theory_ui;
%             lm = launch_theory_ui(ts);
         
            tabTitle = 'Theory';
        [hTabTheoryImport] = ts.create_tab(tabTitle);
        hPanelTheoryImport = uipanel(hTabTheoryImport);
        ts.select_tab(hTabTheoryImport);

        import Fancy.UI.FancyList.FancyListMgr;
        lm = FancyListMgr();
        lm.set_ui_parent(hPanelTheoryImport);
        lm.make_ui_items_listbox();

    
    
            import CBT.Hca.UI.load_theory_ui;
            [lm,cache] = load_theory_ui(lm,ts,cache);

            
%             import CBT.Hca.UI.compute_theory_ui;
%             [lm,cache] = compute_theory_ui(lm,ts,cache);

            import CBT.Hca.UI.compare_t_to_e;
            [lm,cache] = compare_t_to_e(lm,ts,cache);
            
     
            
%             import CBT.TheoryComparison.UI.get_parameters_ui;
%             get_parameters_ui(ts, @on_params_ready);
            
%             [selectedItems, selectedIndices] = get_selected_list_items(lm);
%             
%             for it=1:length(selectedItems)
%             	kymoStructs{it} = selectedItems{it,2};
%                 kymoNames{it} =  selectedItems{it,1};
%             end
%             kymoStructs
            
%             import CBT.Hca.UI.kymo_settings;
%             sets = kymo_settings(); % 
%             
%             kymoStructs = cellfun(@(tl) tl.unalignedKymo(1:min(end,sets.timeFramesNr),:),kymoStructs,'UniformOutput', false);
%             
%             lm.remove_selected_items();
%             lm.add_list_items(kymoNames, kymoStructs);
%             
%             unalignedKymos = cellfun( @(ks) ks,kymoStructs, 'UniformOutput', false);
%             
%             import CBT.Hca.UI.get_unaligned_kymos_tab;
%             hTabUnalignedKymos = CBT.Hca.UI.get_unaligned_kymos_tab(ts); % why does not find it?
%             
%             hPanelUnalignedKymos = uipanel('Parent', hTabUnalignedKymos);
%             delete(allchild(hPanelUnalignedKymos));
%             import OldDBM.Kymo.UI.show_kymos_in_grid;
%             show_kymos_in_grid(hPanelUnalignedKymos, unalignedKymos, kymoNames);

            
        end

        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnOut = FancyListMgrBtn(...
            'Add theory and compare', ...
            @(~, ~, lm) on_make_theory(lm, ts));
    end
end

