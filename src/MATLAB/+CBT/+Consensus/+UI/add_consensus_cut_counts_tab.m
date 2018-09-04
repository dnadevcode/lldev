function [] =  add_consensus_cut_counts_tab(ts, posEndCounts)
    hTabCCC = ts.create_tab('Consensus Cut Counts');
    hPanelCCC = uipanel('Parent', hTabCCC);
    hAxisCCC = axes('Parent', hPanelCCC);
    hold(hAxisCCC, 'on');
    title(hAxisCCC, 'Consensus Cut Counts');
    bar(hAxisCCC, posEndCounts);
end