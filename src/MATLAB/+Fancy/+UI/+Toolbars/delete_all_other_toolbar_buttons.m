function delete_all_other_toolbar_buttons(hFig, keepButtonTags)
    if nargin < 2
        keepButtonTags ={};
    end

    toolbarHandles = findall(hFig, 'tag', 'FigureToolBar');
    buttonHandles = allchild(toolbarHandles);
    tags = arrayfun(@(x) get(x, 'Tag'), buttonHandles, 'UniformOutput', false);

    [~, removeIndices] = setdiff(tags, keepButtonTags);
    delete(buttonHandles(removeIndices))
end