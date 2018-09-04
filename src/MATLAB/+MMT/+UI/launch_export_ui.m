function [] = launch_export_ui(ts, exportDisplayNames, exportValues)
    % LAUNCH_EXPORT_UI
    %   adds a tab with list management UI/functionality for
    %   exportable data
    %  ts
    %   tabbed screen handle
    %  exportDisplayNames
    %   cell array of display names for values
    %  exportValues
    %   cell array of values

    tabTitle = 'Export melting map results';
    [hTab] = ts.create_tab(tabTitle);
    hTabPanel = uipanel(hTab, 'Position', [0, 0, 1, 1]);
    ts.select_tab(hTab);

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs = FancyListMgrBtnSet();
    flmbs.NUM_BUTTON_COLS = 1;
    flmbs.add_button(make_export_cluster_mat_btn());

    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;
    flmbs2.add_button(FancyListMgr.make_select_all_button_template());
    flmbs2.add_button(FancyListMgr.make_deselect_all_button_template());
    
    function [btnExportClusterMat] = make_export_cluster_mat_btn()
        import Fancy.UI.FancyList.FancyListMgrBtn;
        btnExportClusterMat = FancyListMgrBtn(...
            'Export Selected MMT results', ...
            @(~, ~, lm) on_export_selected_cluster_mat(lm));
        function [] = on_export_selected_cluster_mat(lm)
            import MMT.Export.export_cluster_mat;

            selectedItems = lm.get_selected_list_items();
            selectedItemNames = selectedItems(:, 1);
            selectedItemValues = selectedItems(:, 2);
            numSelectedItems = length(selectedItemNames);

            for selectedItemNum=1:numSelectedItems
                clusterKey = selectedItemNames{selectedItemNum};
                clusterConsensusData = selectedItemValues{selectedItemNum};

                export_cluster_mat(clusterConsensusData, clusterKey);

            end
        end            
    end


    import Fancy.UI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(hTabPanel);
    lm.make_ui_items_listbox();
    lm.add_list_items(exportDisplayNames, exportValues);
    lm.add_button_sets(flmbs,flmbs2);
end