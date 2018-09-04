function [] = add_eld_analysis_btns_to_kymo_list_mgr(lm, tsELD, settings)

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;
    flmbs2.add_button(make_run_distance_analysis_btn(tsELD, settings));

    lm.add_button_sets(flmbs2);

    
    

    function [lm] = on_run_distance_analysis(lm, tsELD, settings)
        selectedIndices = lm.get_selected_indices();
        numSelected = length(selectedIndices);
        if numSelected < 1
            questdlg('You must select some kymographs first!', 'Not Yet!', 'OK', 'OK');
            return;
        end
        
        trueValueList = lm.get_true_value_list();
        
        hTabDistanceAnalyses = tsELD.create_tab('Distance Analyses');
        hPanelDistanceAnalyses = uipanel('Parent', hTabDistanceAnalyses);
        import Fancy.UI.FancyTabs.TabbedScreen;
        tsDA = TabbedScreen(hPanelDistanceAnalyses);
        
        
        minOverlap = settings.ELD.minOverlap;
        
        for selectedIdxIdx = 1:numSelected
            kymoIndex = selectedIndices(selectedIdxIdx);
            kymoDispName = lm.get_diplay_names(kymoIndex);
            kymoDispName = kymoDispName{1};
            kymoStruct = trueValueList{kymoIndex};
            unalignedKymo = kymoStruct.unalignedKymo;
            
            hTabCurrKymo = tsDA.create_tab(kymoDispName);
            hPanelCurrKymo = uipanel('Parent', hTabCurrKymo);
            
            hAxesCurrA = axes(hPanelCurrKymo, ...
                'Units', 'normalized', ...
                'Position', [0 0 0.5 1]);
            distances = rand(size(unalignedKymo, 1), 1); %TODO: update
            plot(hAxesCurrA, distances);
            
            hAxesCurrB = axes(hPanelCurrKymo, ...
                'Units', 'normalized', ...
                'Position', [0.5 0 0.5 1]);
            imagesc(hAxesCurrB, unalignedKymo);
            colormap(hAxesCurrB, gray());
        end
        
        
    end
    
    function [btnEnsureAlignment] = make_run_distance_analysis_btn(tsELD, settings)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnEnsureAlignment = FancyListMgrBtn(...
            'Run Distance Analysis', ...
            @(~, ~, lm) on_run_distance_analysis(lm, tsELD, settings));
    end
end