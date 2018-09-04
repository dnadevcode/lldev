function [] = make_selection_ui_for_plot_hist_and_gumbel(tsHistAndGumbel, theoryNames, theoryDataHashes, theoryNamesRaw, theoryDataHashesRaw, bestCCs, gumbelCurveMusByIteration, gumbelCurveBetasByIteration)
    import Fancy.UI.FancyList.FancyListMgr;
    flm = FancyListMgr();

    hTabTheorySelection = tsHistAndGumbel.create_tab('Theory Selection');
    tsHistAndGumbel.select_tab(hTabTheorySelection);
    flm.set_ui_parent(hTabTheorySelection);
    flm.make_ui_items_listbox();

    flm.set_list_items(theoryNames, theoryNames); 


    import Fancy.UI.FancyList.FancyListMgrBtnSet;

    flmbs1 = FancyListMgrBtnSet();
    flmbs1.NUM_BUTTON_COLS = 2;
    flmbs1.add_button(FancyListMgr.make_select_all_button_template());
    flmbs1.add_button(FancyListMgr.make_deselect_all_button_template());

    flmbs2 = FancyListMgrBtnSet();
    flmbs2.NUM_BUTTON_COLS = 1;
    import Fancy.UI.FancyList.FancyListMgrBtn;

    btnMakeSelectionsFromTxt = FancyListMgrBtn('Make Selections from Text', @(~, ~, flm) make_selections_from_text(flm));
    btnPlotsSelectedTheories = FancyListMgrBtn('Make Plots for Selected Theories', @(~, ~, flm) plot_selected_theories(flm));
    flmbs2.add_button(btnMakeSelectionsFromTxt);
    flmbs2.add_button(btnPlotsSelectedTheories);

    flm.add_button_sets(flmbs1, flmbs2);


    function [] = make_selections_from_text(flm)
         theoryNamesRequestedForSelection = prompt_theory_names_to_select();
         selectionIndices = make_theory_selections( ...
                theoryNamesRequestedForSelection, ...
                theoryDataHashes, ...
                theoryNamesRaw, ...
                theoryDataHashesRaw);
        flm.select_some(selectionIndices);

        function [inputtedTheoryNames] = prompt_theory_names_to_select()
            inputtedTheoryNames = inputdlg('Input more theory names to select (comma separated)', 'Select theories by name', 1);
            if iscell(inputtedTheoryNames) && not(isempty(inputtedTheoryNames))
                inputtedTheoryNames = inputtedTheoryNames{1};
            end
            if not(ischar(inputtedTheoryNames))
                inputtedTheoryNames = '';
            end
            inputtedTheoryNames = strtrim(strsplit(inputtedTheoryNames, ','));
            inputtedTheoryNames = inputtedTheoryNames(:);
            inputtedTheoryNames(strcmp('', inputtedTheoryNames)) = [];
        end

        function [selectionIndices] = make_theory_selections(theoryNamesRequestedForSelection, theoryDataHashes, theoryNamesRaw, theoryDataHashesRaw)
            [~, notFoundIndices] = setdiff(theoryNamesRequestedForSelection, theoryNamesRaw);
            if not(isempty(notFoundIndices))
                notFoundMsg = strjoin([{'_'}; theoryNamesRequestedForSelection(notFoundIndices); {'_'}], ''', ''');
                notFoundMsg = notFoundMsg(5:end-4);
                if length(notFoundIndices) > 1
                    notFoundMsg = sprintf('The following %d entries were not options and could not be selected: %s', length(notFoundIndices), notFoundMsg);
                else
                    notFoundMsg = sprintf('The following entry was not an option and could not be selected: %s', notFoundMsg);
                end
                warning(notFoundMsg);
                waitfor(warndlg(notFoundMsg, 'Some entries not found'));
            end
            [~, selectionIndicesRaw] = intersect(theoryNamesRaw, theoryNamesRequestedForSelection(setdiff(1:length(theoryNamesRequestedForSelection), notFoundIndices)));
            selectionDataHashes = unique(theoryDataHashesRaw(selectionIndicesRaw),'stable');
            [~, selectionIndices] = intersect(theoryDataHashes, selectionDataHashes);
        end
    end

    function [] = plot_selected_theories(flm)
        [selectedItems, ~] = flm.get_selected_list_items();
        selectedTheoryNames = selectedItems(:, 1);
        selectedTheoryIndices = cellfun(...
                @(selectedTheoryName) ...
                    find(strcmp(theoryNames, selectedTheoryName), 1, 'first'), ...
                selectedTheoryNames);
            
        import CBT.TheoryComparison.ResultAnalysis.UI.plot_hist_and_gumbel_for_selection;
        plot_hist_and_gumbel_for_selection( ...
            tsHistAndGumbel, ...
            theoryNames, ...
            bestCCs, ...
            gumbelCurveMusByIteration, ...
            gumbelCurveBetasByIteration, ...
            selectedTheoryIndices);
    end
end