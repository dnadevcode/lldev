function [] = test_inputs(seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN, targetAIndices, targetBIndices, targetBestFlipped, targetBestCircShift)
    % import SignalRegistration.XcorrAlign.find_best_alignment_params;
    import SignalRegistration.XcorrAlign.get_top_scores;
    import SignalRegistration.XcorrAlign.compute_alignment_params
    import SignalRegistration.XcorrAlignTest.plot_computed_values;
    import SignalRegistration.XcorrAlignTest.plot_best_alignments;

    lenA = length(seqA);
    lenB = length(seqB);
    
    % [aIndicesAtBestN, bIndicesAtBestN,...
    %     scoresAtBestN, xcorrAtBestN, coverageLenAtBestN,...
    %     scores, xcorrs, coverageLens,...
    %     firstOffset, maxPossibleCoverageLen] = find_best_alignment_params(...
    %         seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN);

    [scoresAtBestN, xcorrAtBestN, coverageLenAtBestN, flipAtBestN, circShiftAtBestN, offsetAtBestN, scores, xcorrs, coverageLens, firstOffset, maxPossibleCoverageLen] = get_top_scores(seqA, seqB, bitmaskA, bitmaskB, circularA, circularB, allowExtraCropping, topN);
    [aIndicesAtBestN, bIndicesAtBestN] = compute_alignment_params(lenA, lenB, circularA, circularB, flipAtBestN, circShiftAtBestN, offsetAtBestN);

    plot_computed_values(scores, xcorrs, coverageLens, maxPossibleCoverageLen);

    hFig = figure();
    hPanel = uipanel('Parent', hFig);
    import Fancy.UI.FancyTabs.TabbedScreen;
    ts = TabbedScreen(hPanel);

    hTabA = ts.create_tab('A');
    hPanelA = uipanel('Parent', hTabA);

    hTabB = ts.create_tab('B');
    hPanelB = uipanel('Parent', hTabB);

    plot_best_alignments(hPanelA, seqA, seqB, {targetAIndices}, {targetBIndices});
    plot_best_alignments(hPanelB, seqA, seqB, aIndicesAtBestN, bIndicesAtBestN);

    % % Ugly piece of code that helps with debugging
    % myVarList = who();
    % for varIdx = 1:length(myVarList)
    %     assignin('base', myVarList{varIdx}, eval(myVarList{varIdx}))
    % end
end