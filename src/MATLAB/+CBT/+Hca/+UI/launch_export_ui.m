function [cache] = launch_export_ui(ts, cache)
     if nargin < 2
        cache = containers.Map();
     end
    
% LAUNCH_EXPORT_UI
    %   adds a tab with list management UI/functionality for
    %   exportable data
    %  ts
    %   tabbed screen handle
    %  exportDisplayNames
    %   cell array of display names for values
    %  exportValues
    %   cell array of values

    tabTitle = 'Export hca comparison results';
    [hTab] = ts.create_tab(tabTitle);
    hTabPanel = uipanel(hTab, 'Position', [0, 0, 1, 1]);
    %ts.select_tab(hTab);

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
            'Export Selected HCA results', ...
            @(~, ~, lm) on_export_selected_cluster_mat(lm));
        function [] = on_export_selected_cluster_mat(lm)
            import CBT.Hca.Export.export_results_mat;

            selectedItems = lm.get_selected_list_items();
            selectedItemNames = selectedItems(:, 1);
            selectedItemValues = selectedItems(:, 2);
            numSelectedItems = length(selectedItemNames);
  
            hcaSessionStruct = cache('hcaSessionStruct');
            sets = cache('sets');

            if ismember(2,cell2mat(selectedItemValues))
                hcaSessionStructLight = struct();
                hcaSessionStructLight.names = hcaSessionStruct.names;
                hcaSessionStructLight.barcodeGen = hcaSessionStruct.barcodeGen;
                hcaSessionStructLight.lengths = hcaSessionStruct.lengths;
                hcaSessionStructLight.rawBarcodesFiltered = hcaSessionStruct.rawBarcodesFiltered;
                hcaSessionStructLight.rawBitmasksFiltered = hcaSessionStruct.rawBitmasksFiltered;
                hcaSessionStructLight.rawBitmasks = hcaSessionStruct.rawBitmasks;
                hcaSessionStructLight.consensusStruct = hcaSessionStruct.consensusStruct;
                hcaSessionStructLight.theoryGen = hcaSessionStruct.theoryGen;
                hcaSessionStructLight.comparisonStructure = hcaSessionStruct.comparisonStructure;
                hcaSessionStructLight.sets = sets;
            end
            
            for selectedItemNum=1:numSelectedItems
                clusterKey = selectedItemNames{selectedItemNum};
                if isequal(selectedItemValues{selectedItemNum},3)
                    exportData = hcaSessionStruct.theoryGen;
                else
                    if isequal(selectedItemValues{selectedItemNum},2)
                        exportData = hcaSessionStructLight;
                    else

                        if isequal(selectedItemValues{selectedItemNum},4)
                            import CBT.Hca.Export.export_sets_txt;
                        	export_sets_txt(sets, clusterKey);
                            break;
                        end
                        hcaSessionStruct.sets = sets;
                        exportData = hcaSessionStruct;
                    end
                end
                 
                export_results_mat(exportData, clusterKey);

            end
        end            
    end

    import Fancy.UI.FancyList.FancyListMgr;
    lm = FancyListMgr();
    lm.set_ui_parent(hTabPanel);
    lm.make_ui_items_listbox();

    
    lm.add_list_items({'hcaSessionStruct','hcaSessionStructLight','theoryGen','sets'}, {1,2,3,4});
    lm.add_button_sets(flmbs,flmbs2);
end