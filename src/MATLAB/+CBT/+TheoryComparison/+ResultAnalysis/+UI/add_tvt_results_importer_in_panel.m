function [] = add_tvt_results_importer_in_panel(tsTvT)
    % add_tvt_results_importer_in_panel -
    %   adds a tab with list management UI/functionality  for
    %    kymographs


    import Fancy.UI.FancyTabs.TabbedScreen;
    hTabTvtResultsImport = tsTvT.create_tab('TvT Results');
    hPanelTvtResultsImport = uipanel(hTabTvtResultsImport);
    tsTvT.select_tab(hTabTvtResultsImport);


    import Fancy.UI.FancyList.FancyListMgr;
    flm = FancyListMgr();
    flm.set_ui_parent(hPanelTvtResultsImport);
    flm.make_ui_items_listbox();


    import Fancy.UI.FancyList.FancyListMgrBtnSet;

    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(FancyListMgr.make_select_all_button_template());
    flmbs1.add_button(FancyListMgr.make_deselect_all_button_template());
    flmbs1.add_button(make_add_tvt_results_button_template());
    flmbs1.add_button(make_remove_tvt_results_button_template());

    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;

    flmbs2.add_button(make_display_analyses_button_template(tsTvT, @get_result_analyses_tabbed_screen));

    flm.add_button_sets(flmbs1, flmbs2);


    function [tsResultAnalyses, hTabTvtResultAnalyses] = get_result_analyses_tabbed_screen(tsTvT)
        persistent persistentHTabTvtResultAnalyses;
        if isempty(persistentHTabTvtResultAnalyses) || not(isvalid(persistentHTabTvtResultAnalyses))
            hTabTvtResultAnalyses = tsTvT.create_tab('TvT Result Analyses');
            persistentHTabTvtResultAnalyses = hTabTvtResultAnalyses;
        else
            hTabTvtResultAnalyses = persistentHTabTvtResultAnalyses;
        end
        persistent persistentTsResultAnalyses;
        if isempty(persistentTsResultAnalyses) || not(isvalid(persistentTsResultAnalyses))
            hPanelTvtResultAnalyses = uipanel(hTabTvtResultAnalyses);
            import Fancy.UI.FancyTabs.TabbedScreen;
            tsResultAnalyses = TabbedScreen(hPanelTvtResultAnalyses);
            persistentTsResultAnalyses = tsResultAnalyses;
        else
            tsResultAnalyses = persistentTsResultAnalyses;
        end
    end

    function [btnAddItems] = make_add_tvt_results_button_template()
        import Fancy.UI.FancyList.FancyListMgrBtn;

        function add_items_from_prompt(flm)
            import CBT.TheoryComparison.ResultAnalysis.Import.prompt_for_tvt_results;
            [aborted, tvtResultNames, tvtResultStructs] = prompt_for_tvt_results();
            if aborted
                return;
            end
            flm.add_list_items(tvtResultNames, tvtResultStructs);
        end
        buttonText = 'Add TvT results';
        callback = @(~, ~, flm) add_items_from_prompt(flm);
        btnAddItems = FancyListMgrBtn(buttonText, callback);
    end

    function [btnRemoveItems] = make_remove_tvt_results_button_template()
        import Fancy.UI.FancyList.FancyListMgrBtn;

        function remove_items_from_prompt(flm)
            indicesForRemoval = flm.get_selected_indices();
            flm.remove_list_items(indicesForRemoval);
        end
        buttonText = 'Remove TvT results';
        callback = @(~, ~, flm) remove_items_from_prompt(flm);
        btnRemoveItems = FancyListMgrBtn(buttonText, callback);
    end

    function [btnDisplayAnalyses] = make_display_analyses_button_template(tsTvT, fn_get_result_analyses_tabbed_screen)
        import Fancy.UI.FancyList.FancyListMgrBtn;
        function [] = display_analyses_for_selected_results(flm, tsTvT, fn_get_result_analyses_tabbed_screen)
            import Fancy.UI.FancyTabs.TabbedScreen;
            [selectedItems, selectedIndices] = flm.get_selected_list_items();
            numResults = length(selectedIndices);
            if numResults < 1
                questdlg('You must select some TvT Results first!', 'Not Yet!', 'OK', 'OK');
                return;
            end
            [tsResultAnalyses, hTabResultAnalyses] = fn_get_result_analyses_tabbed_screen(tsTvT);
            tsTvT.select_tab(hTabResultAnalyses);

            import CBT.TheoryComparison.ResultAnalysis.UI.analyze_and_display_tvt_results;
            for resultNum = 1:numResults
                selectedResultName = selectedItems{resultNum, 1};
                selectedResult = selectedItems{resultNum, 2};

                hTabResult = tsResultAnalyses.create_tab(selectedResultName);
                tsResultAnalyses.select_tab(hTabResult);
                resultPanelHandle = uipanel('Parent', hTabResult);
                tsResultAnalysis = TabbedScreen(resultPanelHandle);

                analyze_and_display_tvt_results(tsResultAnalysis, selectedResultName, selectedResult);
            end
        end
        btnDisplayAnalyses = FancyListMgrBtn('Display Analysis for Selected Results', @(~, ~, flm) display_analyses_for_selected_results(flm, tsTvT, fn_get_result_analyses_tabbed_screen));
    end

end