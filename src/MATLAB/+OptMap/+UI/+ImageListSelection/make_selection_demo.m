function make_selection_demo()
    import OptMap.UI.ImageListSelection.create_make_selection_ui;

    hFig = figure('Name', 'Demo Figure');
    hPanel = uipanel('Parent', hFig);
    hTabgroup = uitabgroup('Parent', hPanel);
    hTabMakeSelection = uitab('Parent', hTabgroup, 'title', 'Make Selection');
    hPanelMakeSelection = uipanel('Parent', hTabMakeSelection);

    function on_selection(selectionMask)
        delete(hTabMakeSelection);
        disp(selectionMask);
    end

    listItemNames = {'include1', 'include2','include3','exclude1', 'exclude2', 'exclude3'};
    listItemImages = {[1 0 0], [1 0 1], [1 1 0], [0 0 0], [0 0 1], [0 1 0]};
    initSelectionMask = [true, true, true, false false, false];

    create_make_selection_ui(...
        @on_selection, ...
        hPanelMakeSelection, ...
        listItemNames, ...
        listItemImages, ...
        initSelectionMask ...
        )
end