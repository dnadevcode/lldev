function [consensusStruct, cache] = generate_consensus_for_selected(lm, cache)
    import CBT.Consensus.Import.Helper.generate_barcodes_for_selected_kymos;
    [kymoStructs] = generate_barcodes_for_selected_kymos(lm, true, true);
    if isempty(kymoStructs)
        consensusStruct = [];
        return;
    end

    import CBT.Consensus.Import.Helper.check_kymo_structs_for_consensus_inputs;
    [aborted, displayNames, rawBarcodes, bpsPerPx_original, rawBgs] = check_kymo_structs_for_consensus_inputs(kymoStructs);
    if aborted
        fprintf('Aborting consensus input generation\n');
        consensusStruct = [];
        return;
    end

    rawBarcodeLens = cellfun(@length, rawBarcodes);

    % Show (in the Command window) which barcodes that are too short, 
    for i = 1:length(rawBarcodeLens)
        if rawBarcodeLens(i) < 10
            onePixelWarningMessage = strcat('!!!*** ',displayNames{i}, ' is only ', num2str(rawBarcodeLens(i)), ' pixels',' ***!!!');
            fprintf('\n %s \n\n',onePixelWarningMessage);
        end
    end

    import CBT.Consensus.UI.Helper.make_barcode_consensus_settings;
    barcodeConsensusSettings = make_barcode_consensus_settings(rawBarcodeLens);
    if isempty(barcodeConsensusSettings)
        return;
    end
    
    import CBT.Consensus.Core.generate_consensus_for_barcodes;
    barcodeConsensusSettings.promptToConfirmTF = true;
    if length(barcodeConsensusSettings.commonLength)>1
        barcodeConsensusSettings.promptToConfirmTF = false;

        consensusStructs = cell(1,length(barcodeConsensusSettings.commonLength));
        commonLengths = barcodeConsensusSettings.commonLength;
        barsInClusters = cell(1,length(commonLengths));

        for i=1:length(commonLengths)    
            barIdx = barcodeConsensusSettings.lC == i;
            barcodeConsensusSettings.commonLength = ceil(mean(rawBarcodeLens(barIdx)));
            if sum(barIdx)>1
                [consensusStructs{i}, cache] = generate_consensus_for_barcodes(rawBarcodes(barIdx), displayNames(barIdx), bpsPerPx_original(barIdx), barcodeConsensusSettings, [], rawBgs(barIdx));
            else
                consensusStructs{i} = [];
            end
            % remove all single barcode results:
            try
                numBars = cellfun(@(x) length(x.barcodeKeys), consensusStructs{i}.clusterResultStructs);
                consensusStructs{i}.clusterResultStructs(find(numBars==1)) = [];
                consensusStructs{i}.clusterKeys(find(numBars==1)) = [];
                consensusStructs{i}.barsInClusters= numBars(numBars>1);
            catch
                consensusStructs{i}.barsInClusters = [];
            end
        end
        
        disp("Consensus generated");
        % now merge these into one maybe..?
        consensusStruct = consensusStructs;
%         for i=2:length(commonLengths) 
%             consensusStruct.clusterResultStructs = [consensusStruct.clusterResultStructs;  consensusStructs{1}.clusterResultStructs];
%         end
        
        % now main struct is the one with best final score
    else
        [consensusStruct, cache] = generate_consensus_for_barcodes(rawBarcodes, displayNames, bpsPerPx_original, barcodeConsensusSettings, cache, rawBgs);
        consensusStruct.barsInClusters = cellfun(@(x) length(x.barcodeKeys), consensusStruct.clusterResultStructs);
    end
end
