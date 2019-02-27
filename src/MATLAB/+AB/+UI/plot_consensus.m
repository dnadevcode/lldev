function [hMenuParent] = plot_consensus(consensusStructs )
    % plot consensus
    
    import Fancy.UI.Templates.create_figure_window;
    [ hMenuParent, tsAB ] = create_figure_window( 'Consensus GUI', 'Consensus' );

	import Fancy.UI.FancyTabs.TabbedScreen;
    import CBT.Consensus.Import.load_consensus_results;
    tmp_isConsensusMask = cellfun(@(x) not(isempty(x)), consensusStructs);
    tmp_cs = consensusStructs(tmp_isConsensusMask);
    for tmp_idx = 1:length(tmp_cs)
        tmp_tabName = sprintf('C %d', tmp_idx);
        tmp_hTabCurrConsensus = tsAB.create_tab(tmp_tabName);
        tmp_hPanelCurrConsensus = uipanel(tmp_hTabCurrConsensus);
        tmp_tsCurrConsensus = TabbedScreen(tmp_hPanelCurrConsensus);
        load_consensus_results(tmp_tsCurrConsensus, tmp_cs{tmp_idx})
    end
    

end

