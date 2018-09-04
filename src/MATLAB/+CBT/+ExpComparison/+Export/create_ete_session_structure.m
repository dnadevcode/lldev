function [eteSessionStruct ] = create_ete_session_structure(comparisonResults,consensusBarcodeNames,stretchedConsensusBarcodes,stretchedConsensusBitmasks,eteSettings)
    % create ETE session structure
    eteSessionStruct.comparisonResults = comparisonResults;
    eteSessionStruct.consensusBarcodeNames=consensusBarcodeNames;
    eteSessionStruct.stretchedConsensusBarcodes = stretchedConsensusBarcodes;
    eteSessionStruct.stretchedConsensusBitmasks=stretchedConsensusBitmasks;
    eteSessionStruct.eteSettings = eteSettings;
end

