function [lC, clusterMeanCenters, consensusInputs, consensusStructs] = compute_cluster_consensus(barcodes, backgrounds, barcodeDisplayNames, consensusSettings)
    % compute_cluster_consensus

    % :param 1: 1
    % :param 2: 2
    %
    % :returns: lenClusterNums

    % rewritten by Albertas Dvirnas
   
    % compute different clusters
    import AB.Processing.compute_clusters;
    [lC, clusterMeanCenters ] = compute_clusters(barcodes, consensusSettings );

    tmp_numLenClusters = max(lC);

	import CBT.Consensus.Import.get_raw_px_edge_length;
    [ epx,~,~,~ ] = get_raw_px_edge_length(...
            consensusSettings.psf, ...
            consensusSettings.dc, ...
            consensusSettings.pxnm, ...
            consensusSettings.skipPromt );
        
    consensusInputs = cell(tmp_numLenClusters, 1);
    consensusStructs = cell(tmp_numLenClusters, 1);
    
    bgmn = cellfun(@(x) nanmean(x),backgrounds, 'UniformOutput', false);
    
    
   

    for i = 1:tmp_numLenClusters
        j = (lC == i);
        if sum(j) < 2
            % only one barcode in the cluster, so we don't have anything to
            % cluster...
            continue;
        end
        
        % average length
        tmp_commonLength_pixels = clusterMeanCenters(i);
        
        % if barcodes are empty, continue. Alternatively, check if bitmasks
        % are 0
        if tmp_commonLength_pixels < 1
            continue;
        end

%         hcaSessionStruct = struct();
%         hcaSessionStruct.rawBarcodes = barcodes(j);
%         hcaSessionStruct.lengths = cellfun(@(x) length(x),hcaSessionStruct.rawBarcodes);
% 
%         hcaSessionStruct.rawBitmasks = barcodes(j);
%         for k=1:length(hcaSessionStruct.rawBarcodes)
%             import CBT.Bitmasking.generate_zero_edged_bitmask_row;
%             hcaSessionStruct.rawBitmasks{k} = generate_zero_edged_bitmask_row(hcaSessionStruct.lengths(k));
%         end
%         
%         sets =consensusSettings;
%         sets.prestretchMethod = 0;
%         sets.barcodeConsensusSettings.aborted = 0;
%          % generate consensus
%         import CBT.Hca.UI.Helper.gen_consensus
%         hcaSessionStruct = gen_consensus(hcaSessionStruct,sets);
% 
%         % select consensus
%         import CBT.Hca.UI.Helper.select_consensus
%         hcaSessionStruct = select_consensus(hcaSessionStruct,sets);
% 
% 
%     
    
        % run consensus structure
        import CBT.Consensus.Import.Helper.gen_consensus_inputs_struct;
        consensusInputs{i} = gen_consensus_inputs_struct(...
            barcodeDisplayNames(j), ...
            barcodes(j), ...
            zeros(1,sum(j )), ...
            consensusSettings.ct, ...
            tmp_commonLength_pixels, ...
            epx, ...
            consensusSettings.pxnm, bgmn(j), consensusSettings.normSetting);

        cache = containers.Map();
        import CBT.Consensus.Core.make_consensus_as_struct;
        [consensusStructs{i} , cache] = make_consensus_as_struct( ...
            consensusInputs{i}.barcodes, ...
            consensusInputs{i}.bitmasks, ...
            consensusInputs{i}.displayNames,...
            consensusInputs{i}.otherBarcodeData, ...
            consensusInputs{i}.clusterScoreThresholdNormalized, ...
            cache,  barcodes(j),bgmn(j));
    end

    
end
