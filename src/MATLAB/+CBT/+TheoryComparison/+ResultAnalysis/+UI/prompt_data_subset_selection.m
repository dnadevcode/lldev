function [theoryNames, bestCCsMat, theoryLengths_bp, theoryDataHashes] = prompt_data_subset_selection(bestCCsRaw, theoryDataHashesRaw, theoryNamesRaw, theoryLengths_bpRaw)
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_should_merge_duplicates;
    import CBT.TheoryComparison.ResultAnalysis.UI.prompt_indices_range;

    shouldMergeDuplicates = prompt_should_merge_duplicates();

    if shouldMergeDuplicates
        [~, ui] = unique(theoryDataHashesRaw,'stable');
        theoryNames = arrayfun(@(i) strjoin(theoryNamesRaw(strcmp(theoryDataHashesRaw, theoryDataHashesRaw{i})),'/'), ui, 'UniformOutput', false);
        bestCCsMat = bestCCsRaw(ui, ui);
        theoryLengths_bp = theoryLengths_bpRaw(ui);
        theoryDataHashes = theoryDataHashesRaw(ui);
    else
        theoryNames = theoryNamesRaw;
        bestCCsMat = bestCCsRaw;
        theoryLengths_bp = theoryLengths_bpRaw;
        theoryDataHashes = theoryDataHashesRaw;
    end
    % assignin('base', 'theoryNames', theoryNames);
    % assignin('base', 'bestCCs', bestCCsMat);
    % assignin('base', 'theoryLengths_bp', theoryLengths_bp);
    % assignin('base', 'theoryDataHashes', theoryDataHashes);

    indicesToInclude = prompt_indices_range(theoryLengths_bp);
    theoryNames = theoryNames(indicesToInclude);
    bestCCsMat = bestCCsMat(indicesToInclude, indicesToInclude);
    theoryLengths_bp = theoryLengths_bp(indicesToInclude);
    theoryDataHashes = theoryDataHashes(indicesToInclude);
end