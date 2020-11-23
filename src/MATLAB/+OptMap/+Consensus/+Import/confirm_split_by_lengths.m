function [notOK, barcodeConsensusSettings] = confirm_split_by_lengths(rawBarcodeLens, barcodeConsensusSettings)

    lenRangeFactor = barcodeConsensusSettings.maxStretch;
    % ask for lenRangeFactor
    prompt = {strcat(['Split ' num2str(length(rawBarcodeLens)) ' barcodes based on length factor:'])};
    dlgtitle = 'Enter lenRangeFactor';
    dims = [1 35];
    definput = {num2str(lenRangeFactor)};
    answer = inputdlg(prompt,dlgtitle,dims,definput);
    lenRangeFactor = str2double(answer{1});
    
%     barcodeConsensusSettings.lenRangeFactor = 1.3;
    % run batch comparison if too many barcodes
    import OptMap.Consensus.compute_clusters;
    [lC, clusterMeanCenters ] = compute_clusters(rawBarcodeLens, lenRangeFactor );

    continueGenPrompt = sprintf('Barcodes split (%d clusters) with mean lengths (px). %s Continue?', ...
        length(clusterMeanCenters), ...
        cell2mat(arrayfun(@(x) strcat(num2str(x),','),clusterMeanCenters,'UniformOutput',false)'));
    continueGenChoice = questdlg(continueGenPrompt, 'Continue consensus generation?', 'Yes', 'No', 'Yes');
    notOK = not(strcmp(continueGenChoice, 'Yes'));
    
    barcodeConsensusSettings.lC = lC;
    barcodeConsensusSettings.commonLength = clusterMeanCenters;
  
end