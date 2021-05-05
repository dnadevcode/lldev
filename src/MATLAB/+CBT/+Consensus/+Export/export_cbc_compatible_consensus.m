function [cStruct] = export_cbc_compatible_consensus( consensusStructs, consensusInputs,rawBarcodes,barcodeConsensusSettings)
    % export_cbc_compatible_consensus
    % TODO: write code that extracts the structure in the format compatible
    % with CBC_GUI
    
    % comparible to consensusStruct:
    %                           inputs: [1×1 struct]
    %                      keyList: {47×1 cell}
    %            keyListSimplified: {47×1 cell}
    %            finalConsensusKey: '[7,[9,[5,[2,[[16,[4,[[13,[[11,12],[8,[23,[10,[14,19]]]]]],[17,18]]]],[[15,[21,6]],[[1,[22,24]],[20,3]]]]]]]]'
    %            barcodeStructsMap: [47×1 containers.Map]
    %         consensusMergingTree: [23×3 double]
    %                  clusterKeys: {18×1 cell}
    %     clusterAssignmentsMatrix: [24×1 double]
    %         clusterResultStructs: {18×1 cell}
    %                        cache: [1104×1 containers.Map]
    %                    timestamp: 03-May-2021 16:04:44
    %                formatVersion: '0.1.0'

    
%     idx = 5; % from which step cluster are we taking ??

    %% INPUTS
    % input structure: has to contain rawBarcodes as well
    inputs = struct;

    inputs.rawBarcodes = rawBarcodes; % raw barcodes
    inputs.barcodes = consensusInputs.barcodes; % rescaled barcodes
    inputs.barcodeBitmasks = consensusInputs.bitmasks; % rescaled bitmasks
    inputs.barcodeAliases = consensusInputs.displayNames; % display names
    inputs.otherBarcodeData = consensusInputs.otherBarcodeData; % other data, i.e. stretch factor
    inputs.clusterThresholdScore = consensusInputs.clusterScoreThresholdNormalized; %cluster thresh
    inputs.rawBgs = consensusInputs.rawBgs; % backgrounds
    inputs.barcodeConsensusSettings = barcodeConsensusSettings; % barcode gen settings, can be used i.e to generate bitmask

    cStruct = struct;
    cStruct.inputs = inputs;

    %% barcodeStructsMap
    
    % this was previously reported twice
    cStruct.formatVersion = '0.2.0';
    cStruct.timestamp = consensusStructs.time;

    import CBT.Consensus.Helper.extract_barcodestructsmap;
    [cStruct.barcodeStructsMap,cStruct.keyList,M] = extract_barcodestructsmap(inputs,consensusStructs);
    
    bestPossibleScore = sqrt(length( inputs.barcodes{1})); 

    w1= cellfun(@(x) M(regexprep(num2str(sort(x{1})),' +',',')),consensusStructs.treeStruct.clusteredBar)';
    w2 = cellfun(@(x) M(regexprep(num2str(sort(x{2})),' +',',')),consensusStructs.treeStruct.clusteredBar)';
    cStruct.consensusMergingTree = [w1 w2  1-consensusStructs.treeStruct.maxScore'/bestPossibleScore];

    %% CLUSTERS
    % this could be moved to the post-processing of CBC data, since we can
    % vary the cutoff!
    clusterAssignmentsMatrix = cluster(cStruct.consensusMergingTree , 'cutoff', 1 - consensusInputs.clusterScoreThresholdNormalized, 'criterion', 'distance');
    numClusters = max(clusterAssignmentsMatrix);
    cStruct.clusterAssignmentsMatrix = clusterAssignmentsMatrix;
    
    % here we extract data for each cluster
%     getKeyComponentNums = @(k) str2num(strrep(strrep(strrep(k, ']', ''), '[', ''), ',', '; ')); %#ok<ST2NM>
%     formatSortedDash = @(componentNums) strjoin(arrayfun(@(x) num2str(x), num2str(sort(componentNums)), 'UniformOutput', false), '-');
%     keyListSimplified = cellfun(@(k) formatSortedDash(getKeyComponentNums(k)), cStruct.keyList, 'UniformOutput', false);

    
    clusterKeys = cell(numClusters, 1);
    clusterResultStructs = cell(numClusters, 1);
%     clusterNum = 1;
%     clusterSizes = zeros(numClusters, 1);
    import CBT.Consensus.Helper.extract_consensus_aligned_barcodes;
    for clusterNum=1:numClusters
        componentNums = find(clusterAssignmentsMatrix == clusterNum);
        
        idd = M(regexprep(num2str(sort(componentNums')),' +',','));
        clustId = idd-length(inputs.barcodes);
        clusterKeys{clusterNum} = cStruct.keyList{idd};
        
        if clustId>0
        
            %
            clusterResultStructs{clusterNum}.alignedBarcodes = arrayfun(@(x) consensusStructs.treeStruct.barcodes{clustId}(x,:), 1:size(consensusStructs.treeStruct.barcodes{clustId},1),'un',false)';
            clusterResultStructs{clusterNum}.alignedBarcodeBitmasks = arrayfun(@(x) ~isnan(consensusStructs.treeStruct.barcodes{clustId}(x,:)), 1:size(consensusStructs.treeStruct.barcodes{clustId},1),'un',false)';
            clusterResultStructs{clusterNum}.barcodeKeys = arrayfun(@(x) num2str(x),sort(componentNums'),'un',false)';
            clusterResultStructs{clusterNum}.barcodes = inputs.barcodes(sort(componentNums'));
            clusterResultStructs{clusterNum}.barcodeBitmasks = inputs.barcodeBitmasks(sort(componentNums'));
                
            clusterResultStructs{clusterNum}.flipTFs =  consensusStructs.treeStruct.barOrientation{clustId}(:,2)-1;
            clusterResultStructs{clusterNum}.circShifts =  consensusStructs.treeStruct.barOrientation{clustId}(:,1)-1;

%         clusterResultStructs{clusterNum}.circShifts = ;

%             clusterNum=clusterNum+1;
        else
            clusterResultStructs{clusterNum}.alignedBarcodes =  inputs.barcodes(idd);
            clusterResultStructs{clusterNum}.alignedBarcodeBitmasks = inputs.barcodeBitmasks(idd);
            clusterResultStructs{clusterNum}.barcodeKeys = {num2str(idd)};
            clusterResultStructs{clusterNum}.barcodes =   inputs.barcodes(idd);
            clusterResultStructs{clusterNum}.barcodeBitmasks = inputs.barcodeBitmasks(idd);
            clusterResultStructs{clusterNum}.flipTFs =  0;
            clusterResultStructs{clusterNum}.circShifts =  0;

        end
    end

    cStruct.clusterResultStructs = clusterResultStructs;
    cStruct.clusterKeys = clusterKeys;
        
%         cStruct.barcodeStructsMap(cStruct.keyList{idd})
        
%         % single barcode clusters should be skipped..
%         clusterKey = cStruct.keyList{find(strcmp(keyListSimplified, formatSortedDash(componentNums)), 1)};
%         clusterSizes(clusterNum) = length(componentNums);
%         clusterKeys{clusterNum} = clusterKey;
%         
%         % need to take the correct name from the structure
%         clusterResultStruct{clusterNum}.alignedBarcodes = consensusStructs.treeStruct.barcodes{clustId};
%         
%         import CBT.Consensus.Helper.extract_consensus_components;
%         import Barcoding.Reorienting.reorient_barcode_and_bitmask;
% 
%         [barcodeKeys, barcodes, barcodeBitmasks, flipTFs, circShifts] = extract_consensus_components(consensusKey, barcodeStructsMap);
%         numBarcodes = size(barcodeKeys, 1);
%         alignedBarcodes = cell(numBarcodes, 1);
%         alignedBarcodeBitmasks = cell(numBarcodes, 1);
%         for barcodeNum=1:numBarcodes
%         [alignedBarcodes{barcodeNum}, alignedBarcodeBitmasks{barcodeNum}] = reorient_barcode_and_bitmask(barcodes{barcodeNum}, barcodeBitmasks{barcodeNum}, flipTFs(barcodeNum), circShifts(barcodeNum));
%         end
%     
%         
%         %% change/remove this function since now they are already aligned in the consensus structur
%         clusterResultStruct = struct;
%         [ ...
%             clusterResultStruct.barcodeKeys, ...
%             clusterResultStruct.alignedBarcodes, ...
%             clusterResultStruct.alignedBarcodeBitmasks, ...
%             clusterResultStruct.barcodes, ...
%             clusterResultStruct.barcodeBitmasks, ...
%             clusterResultStruct.flipTFs, ...
%             clusterResultStruct.circShifts ...
%             ] = extract_consensus_aligned_barcodes(clusterKey, barcodeStructsMap);
%         clusterResultStructs{clusterNum} = clusterResultStruct;
%     end
    

%     cStruct.clusterKeys = % base barcode for each cluster..


%     
%                     clusterKeys: {15×1 cell}
%     clusterAssignmentsMatrix: [15×1 double]
%         clusterResultStructs: {15×1 cell}
%     cStruct.barcodeStructsMap = extract_barcodestructsmap( );
   
    % now cluster results struct - this is a little post processing step
    % since it depends on cluster threshold (which can be changed manually)
        % merging tree

%     [cStruct.consensusMergingTree  consensusStruct.consensusMergingTree]
% 
%     %
%     1-max(maxscore(:))/sqrt(405)
%     1.0000    2.0000    0.4185    1.0000    2.0000    0.4185
%     8.0000    9.0000    0.4466    8.0000    9.0000    0.4466
%     7.0000   19.0000    0.4232    7.0000   19.0000    0.4232
%    12.0000   15.0000    0.4974   15.0000   20.0000    0.4806
%    20.0000   21.0000    0.4269   12.0000   21.0000    0.4608
%%
    
    %consensusStruct
%     consensusStruct.keyList = keyList; % ok!
%     consensusStruct.keyListSimplified = keyListSimplified;
%     consensusStruct.finalConsensusKey = consensusKeyPool{1};
%     consensusStruct.barcodeStructsMap = barcodeStructsMap;
%     consensusStruct.consensusMergingTree = consensusMergingTree;
%     consensusStruct.clusterKeys = clusterKeys;
%     consensusStruct.clusterAssignmentsMatrix = clusterAssignmentsMatrix;
%     consensusStruct.clusterResultStructs = clusterResultStructs;
%     consensusStruct.cache = subcache;
%     consensusStruct.timestamp = datetime('now');
%     consensusStruct.formatVersion = '0.1.0';
    
    
    % can we create keyList with []?
%     
%      % key lists. add all barcodes to the beginning of the keylist
%      cStruct.keyList =  [arrayfun(@(x) num2str(x), 1:length(inputs.barcodes),'un',false)';
%      cellfun(@(x) regexprep(num2str(cell2mat(x)),' +',','), consensusStructs.treeStruct.clusteredBar,'UniformOutput',false)'];
%      cStruct.keyListSimplified = cStruct.keyList ; % where is this used? make this to list of integers
% 
%      
%     cStruct.keyList = [arrayfun(@(x)  regexprep(num2str(x),' +',','), find(consensusStructs.treeStruct.barMatrix{idx})', 'UniformOutput', false);...
%         cellfun(@(x) regexprep(num2str(cell2mat(x)),' +',',') ,consensusStructs.treeStruct.clusteredBar,'UniformOutput',false)'];
%     hcaClusterConsensusData.details.consensusStruct.keyListSimplified = hcaClusterConsensusData.details.consensusStruct.keyList ;
%     hcaClusterConsensusData.details.consensusStruct.finalConsensusKey = hcaClusterConsensusData.clusterKey;
%     % TODO: add more keys, if there are some unmerged clusters for given selected CC
%     % threshold value, otherwise return a single one
%     hcaClusterConsensusData.details.consensusStruct.clusterKeys ={hcaClusterConsensusData.clusterKey };
% 
%     hcaClusterConsensusData.details.consensusStruct.clusterAssignmentsMatrix = consensusStructs.treeStruct.barMatrix{idx}';
 
    
    
%     
%     
%     % last index, or either index..
%     idx = length(consensusStructs.consensusStruct);
% 
%     % now generate the output which is equivalent to CBC output (so it is
%     % loadable with CBC software completely
% 
%     hcaClusterConsensusData = [];
%     
% 
%     
%     hcaClusterConsensusData.barcode = consensusStructs.consensusStruct{idx}.rawBarcode;
%     hcaClusterConsensusData.bitmask = consensusStructs.consensusStruct{idx}.rawBitmask;
%     hcaClusterConsensusData.indexWeights = consensusStructs.consensusStruct{idx}.indexWeights;
%     hcaClusterConsensusData.stdErrOfTheMean = consensusStructs.consensusStruct{idx}.stdErrOfTheMean;
%     hcaClusterConsensusData.clusterKey = num2str(sort(consensusStructs.consensusStruct{idx}.indices));
%     hcaClusterConsensusData.clusterKey = regexprep(hcaClusterConsensusData.clusterKey,' +',',');
%     % strrep(,'   ', ',')
%     % hcaClusterConsensusData.clusterResultStruct.barcodeBitmasks
%     % hcaClusterConsensusData.clusterResultStruct.barcodeKeys = 
%     hcaClusterConsensusData.clusterResultStruct.barcodes = cellfun(@(x) x.stretchedBarcode,barcodeGen(consensusStructs.treeStruct.barMatrix{idx})','UniformOutput',false);
%     hcaClusterConsensusData.clusterResultStruct.barcodeBitmasks = cellfun(@(x) x.stretchedrawBitmask,barcodeGen(consensusStructs.treeStruct.barMatrix{idx})','UniformOutput',false);
%     hcaClusterConsensusData.clusterResultStruct.flipTFs = logical(consensusStructs.treeStruct.barOrientation{idx}(:,2)-1);
%     hcaClusterConsensusData.clusterResultStruct.circShifts = consensusStructs.treeStruct.barOrientation{idx}(:,1)-1;
%     hcaClusterConsensusData.clusterResultStruct.barcodeKeys = arrayfun(@(x) num2str(x), find(consensusStructs.treeStruct.barMatrix{idx})', 'UniformOutput', false);
%     hcaClusterConsensusData.clusterResultStruct.alignedBarcodes = num2cell(consensusStructs.treeStruct.barcodes{idx},2);
%     hcaClusterConsensusData.clusterResultStruct.alignedBarcodeBitmasks = num2cell(~isnan(consensusStructs.treeStruct.barcodes{idx}),2);
% 
%     % this is unnecessary..
%     hcaClusterConsensusData.details.consensusStruct.clusterResultStructs = {hcaClusterConsensusData.clusterResultStruct};
%     
%     % this was previously reported twice
%     hcaClusterConsensusData.details.consensusStruct.formatVersion = '0.1.0';
%     hcaClusterConsensusData.details.consensusStruct.timestamp = consensusStructs.consensusStruct{idx}.time;
% 
% 
% %     % inputs
% %     hcaClusterConsensusData.details.consensusStruct.inputs.barcodes =  cellfun(@(x) x.stretchedBarcode,barcodeGen','UniformOutput',false);
%     hcaClusterConsensusData.details.consensusStruct.inputs.barcodeBitmasks =   cellfun(@(x) x.stretchedrawBitmask,barcodeGen','UniformOutput',false);
%     hcaClusterConsensusData.details.consensusStruct.inputs.barcodeAliases =   cellfun(@(x) x.name,fliplr(kymoStructs)','UniformOutput',false);
%     hcaClusterConsensusData.details.consensusStruct.inputs.rawBarcodes =   cellfun(@(x) x.rawBarcode,barcodeGen','UniformOutput',false);
%     hcaClusterConsensusData.details.consensusStruct.inputs.rawBgs =   cellfun(@(x) x.rawBg,barcodeGen','UniformOutput',false);
%     hcaClusterConsensusData.details.consensusStruct.inputs.clusterThresholdScore = sqrt(length(barcodeGen{1}.stretchedBarcode))*sets.consensus.threshold; %sqrt(N)*clusterthresh
% 
%     stretchFactors = cellfun( @(x) x.stretchFactor, barcodeGen);
%     for K = 1 : numel(hcaClusterConsensusData.details.consensusStruct.inputs.barcodes)
%         hcaClusterConsensusData.details.consensusStruct.inputs.otherBarcodeData{K}.stretchFactor = stretchFactors(K);
%         hcaClusterConsensusData.details.consensusStruct.inputs.otherBarcodeData{K}.nmPerPx_original = sets.bitmasking.prestretchPixelWidth_nm;
%         hcaClusterConsensusData.details.consensusStruct.inputs.otherBarcodeData{K}.nmPerPx_stretched = sets.bitmasking.prestretchPixelWidth_nm*stretchFactors(K);
%         hcaClusterConsensusData.details.consensusStruct.inputs.otherBarcodeData{K}.bpsPerPx_original = NaN;
%         hcaClusterConsensusData.details.consensusStruct.inputs.otherBarcodeData{K}.bpsPerPx_stretched = NaN;
%     end

    % hcaClusterConsensusData.clusterKey = regexprep(hcaClusterConsensusData.clusterKey,' +',',');

      % next is clusterConsensusData.details.consensusStruct.barcodeStructsMap
    % for each Key, the value is 
    %        maxWeight: 1
    %     indexWeights: [1×212 logical] // how many have been averaged for each
    %     position
    %            alias: 'P18_170607_OD4_100msExp_9-Edited_molecule_1_kymograph.tif Mol #1'
    %          barcode: [1×212 double] // why we need this here too?
    %          parents: {} % this stores the name of previous 2 parents,
    %          orientation and circular shift
    %        bestScore: NaN // not sure what the best score is?
    %      xcorrAtBest: NaN // nan's for first 44 elements since those are just
    %      initial 
    %      
    % mergin tree
    % idx1 idx2 1-xcorr score
% 
%     % merging tree
%     w1= cellfun(@(x) M(regexprep(num2str(sort(x{1})),' +',',')),consensusStructs.treeStruct.clusteredBar)';
%     w2 = cellfun(@(x) M(regexprep(num2str(sort(x{2})),' +',',')),consensusStructs.treeStruct.clusteredBar)';
%     hcaClusterConsensusData.details.consensusStruct.consensusMergingTree = [w1 w2  1-consensusStructs.treeStruct.maxCorCoef'];
% 
%     % cache saves all the xcorrs.
%     hcaClusterConsensusData.details.consensusStruct.cache = containers.Map();
%     clusterConsensusData = hcaClusterConsensusData;
%     timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
% 
%     save(fullfile(sets.output,strcat([timestamp 'cluster.mat'])),'-v7.3','clusterConsensusData')


%%
%   import CBT.Consensus.Helper.make_cluster_structs;
%     [clusterKeys, clusterConsensusDataStructs] = make_cluster_structs(cStruct);
% 
%     import CBT.Consensus.UI.launch_export_ui;
%     launch_export_ui(ts, clusterKeys, clusterConsensusDataStructs)
% 
%     import CBT.Consensus.UI.plot_clusters_concentrically;
%     hTabConcentric = plot_clusters_concentrically(ts, clusterKeys, clusterConsensusDataStructs);
% 
%     import CBT.Consensus.UI.plot_clusters_linearly;
%     plot_clusters_linearly(ts, consensusStruct);
% 
%     hTabPairwiseConsensusHistory = ts.create_tab('Pairwise Consensus History');
%     ts.select_tab(hTabPairwiseConsensusHistory);
%     hPanelPairwiseConsensusHistory = uipanel(hTabPairwiseConsensusHistory);
%     import CBT.Consensus.UI.plot_pairwise_consensus_history;
%     plot_pairwise_consensus_history(consensusStruct, hPanelPairwiseConsensusHistory);
% 
%     hTabConsensusDendros = ts.create_tab('Consensus Dendrograms');
%     ts.select_tab(hTabConsensusDendros);
%     hPanelConsensusDendros = uipanel(hTabConsensusDendros);
%     import CBT.Consensus.UI.plot_consensus_dendrograms;
%     plot_consensus_dendrograms(consensusStruct, hPanelConsensusDendros);

end

