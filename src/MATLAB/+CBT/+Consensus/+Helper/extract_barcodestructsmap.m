function [barcodeStructsMap,allKeys,M] = extract_barcodestructsmap(inputs,consensusStructs)
%      extract barcode struct map
%   we should be able to convert between averaged barcodes and a
%   hierarchical cluster, i.e.
%   consensusStructs and previous consensusStruct should give exactly the
%   same results if exactly the same calculation is performed.
%   consensusStructs is designed so that the barcodes would be easier
%   accessed, but the information about best alignments should still be
%   stored
 
%% CLEAN: consensus results to consensus structure


    % create container map with values of each cluster key
    ids = [1:length(inputs.barcodes)];
    names = arrayfun(@(x) num2str(x),ids, 'UniformOutput',false);
    M = containers.Map(names,ids);
    barcodeStructsMap =containers.Map();

    % this will store key maps
    keysMap =containers.Map();


    % and all (initial) barcodes
    for i=1:length(ids)
        weights =inputs.barcodeBitmasks{i};
        st.maxWeight = max(weights);
        st.indexWeights = weights;
        st.alias = inputs.barcodeAliases{i};
        st.barcode = inputs.barcodes{i};
        st.parents =  {} ;
        st.bestScore = NaN; % just the barcode, so best score is nan
        st.xcorrAtBest = NaN; % just the barcode, so best corr is nan
        barcodeStructsMap(num2str(i)) = st;
        keysMap(num2str(i)) = num2str(i);
    end


    % keyMap calculation, separate function. keysMap relates unordered
    % indexes to ordered indexes
       % label for two function
    eltLabel= @(x) regexprep(num2str(sort(cell2mat(x))),' +',',');
    % single label function
    singleLabel= @(x) regexprep(num2str(sort(x)),' +',',');
    idd = length(inputs.barcodes); 

    for i=1:length(consensusStructs.treeStruct.clusteredBar)
        newelt = eltLabel(consensusStructs.treeStruct.clusteredBar{i}); % new element, order does not matter
        % generate bracket structure, i.e. where order matters for the
        % alignment
        key1 = keysMap(singleLabel(consensusStructs.treeStruct.clusteredBar{i}{1}));
        key2 = keysMap(singleLabel(consensusStructs.treeStruct.clusteredBar{i}{2}));
        newElement=['['  key1 ',' key2 ']'];
        keysMap(newelt) = newElement; % this gives the name as in old structure which preserve hierarchy    
        
        M(newelt)=idd+1; % how these clusters are labelled in output matrices
        idd = idd+1;
    end
    
    % best possible score (since we need to normalize)
    bestPossibleScore = sqrt(length( inputs.barcodes{1})); 
    % number of barcodes
    
    keys = cell(1,length(consensusStructs.treeStruct.clusteredBar));
    % go through the consensus cluster here
    for i=1:length(consensusStructs.treeStruct.clusteredBar)
        newelt = eltLabel(consensusStructs.treeStruct.clusteredBar{i}); % new element, order does not matter

        st.indexWeights = sum(~isnan(consensusStructs.treeStruct.barcodes{i}));
        st.maxWeight = max(st.indexWeights);
        st.barcode = nanmean(consensusStructs.treeStruct.barcodes{i});
        
        % now in parents, we report position and orientation for each
        branchLeftIdx = consensusStructs.treeStruct.clusteredBar{i}{1};
        branchRightIdx = consensusStructs.treeStruct.clusteredBar{i}{2};
        allBars = find(consensusStructs.treeStruct.barMatrix{i}); % sorted barcode indexes
        
        % positions
        posLeft = fliplr(consensusStructs.treeStruct.barOrientation{i}(arrayfun(@(x) find(allBars==x),branchLeftIdx),:));
        posRight = fliplr(consensusStructs.treeStruct.barOrientation{i}(arrayfun(@(x) find(allBars==x),branchRightIdx),:));
        posLeft = posLeft-1; % correct for first index
        posRight = posRight-1; % correct for first index & orientation index

        
        st.parents = cell(1,2);
        st.parents{1} = [branchLeftIdx' posLeft];
        st.parents{2} = [branchRightIdx' posRight];

        st.bestScore =  consensusStructs.treeStruct.maxScore(i)/bestPossibleScore;
        st.xcorrAtBest = consensusStructs.treeStruct.maxCorCoef(i);
        st.alias ='';
        keys{i} = keysMap(newelt);


        barcodeStructsMap(keysMap(newelt)) = st;
    end
    
    allKeys = [arrayfun(@(x) num2str(x) , 1:length(inputs.barcodes) , 'UniformOutput' , false) keys];



% a = consensusStruct.barcodeStructsMap.values;
% b = barcodeStructsMap.values;
% 
% i=1
% % test a given element and it's score
% newelt = regexprep(num2str(sort(cell2mat(consensusStructs.treeStruct.clusteredBar{i}))),' +',',');
% newElement=['[', newelt ']'];
% consensusStruct.barcodeStructsMap(newElement)
% barcodeStructsMap(newElement)
% % st
% 
% consensusStruct.barcodeStructsMap(newElement).parents{1}
% barcodeStructsMap(newElement).parents{1}
% 
% 
% consensusStruct.barcodeStructsMap(newElement).parents{2}
% barcodeStructsMap(newElement).parents{2}
% 
% 
% % create container map with values of each cluster key
% ids = [1:length(inputs.barcodes)];
% names = arrayfun(@(x) num2str(x),ids, 'UniformOutput',false);
% M = containers.Map(names,ids);
% barcodeStructsMap =containers.Map();
% % barcodeStructsMap = containers.Map(names,ids);
% 
% keysMap =containers.Map();
% 
% 
% % and all barcodes
% for i=1:length(ids)
%     weights =inputs.barcodeBitmasks{i};
%     st.maxWeight = max(weights);
%     st.indexWeights = weights;
%     st.alias = inputs.barcodeAliases{i};
%     st.barcode = inputs.barcodes{i};
%     st.parents =  {} ;
% %     st.key = num2str(i);
%     st.bestScore = NaN; % just the barcode, so best score is nan
%     st.xcorrAtBest = NaN; % just the barcode, so best corr is nan
%     barcodeStructsMap(num2str(i)) = st;
%     keysMap(num2str(i)) = num2str(i);
% end
% 
%     eltLabel= @(x) regexprep(num2str(sort(cell2mat(x))),' +',',');
%    singleLabel= @(x) regexprep(num2str(sort(x)),' +',',');
% 
%     
%      bestPossibleScore = sqrt(length( inputs.barcodes{1})); 
%     idd = length(inputs.barcodes); 
%     for i=1:length(consensusStructs.treeStruct.clusteredBar)
% %         barcodeStructsMap()
%         newelt = eltLabel(consensusStructs.treeStruct.clusteredBar{i});
%         % generate bracket structure
%         key1 = keysMap(singleLabel(consensusStructs.treeStruct.clusteredBar{i}{1}));
%         key2 = keysMap(singleLabel(consensusStructs.treeStruct.clusteredBar{i}{2}));
%         newElement=['['  key1 ',' key2 ']'];
%         keysMap(newelt) = newElement; % this gives the name as in old structure which preserve hierarchy
%         
%         M(newelt)=idd+1;
%         idd = idd+1;
%         % structure
% %         st.key = newElement;
%         st.indexWeights = sum(~isnan(consensusStructs.treeStruct.barcodes{i}));
%         st.maxWeight = max(st.indexWeights);
%         st.barcode = nanmean(consensusStructs.treeStruct.barcodes{i});
%         % parents, TF and circshift is not compatible with the old code, since
%         % we circularly shift and rotate each molecule, rather than update an
%         % average
%         % here we also save positions and orientations
%         
%         % now in parents, we report position and orientation for each
%         
%         branchLeftIdx = consensusStructs.treeStruct.clusteredBar{i}{1};
%         branchRightIdx = consensusStructs.treeStruct.clusteredBar{i}{2};
%         
% 
%         posLeft = fliplr(consensusStructs.treeStruct.barOrientation{i}(1:length(branchLeftIdx),:));
%         posRight = fliplr(consensusStructs.treeStruct.barOrientation{i}(length(branchLeftIdx)+1:end,:));
%         posLeft = posLeft-1; % correct for first index
%         posRight = posRight-1; % correct for first index & orientation index
% 
% %         posLeft(:,1) = posLeft(:,1)+1; % correct for first index
% %         posRight(:,1) = posRight(:,1)+1; % correct for first index
% 
%         
%         st.parents = cell(1,2);
%         st.parents{1} = [branchLeftIdx' posLeft];
%         st.parents{2} = [branchRightIdx' posRight];
% 
% %         arrayfun(@(x) consensusStructs.treeStruct.clusteredBar{i}{2}.
%         % barcode in the cluster, rather than for the average
% %         st.parents =  {{regexprep(num2str(consensusStructs.treeStruct.clusteredBar{i}{1}),' +',','),[0],[0]},{regexprep(num2str(consensusStructs.treeStruct.clusteredBar{i}{2}),' +',','),[0],[0]} } ;
%         st.bestScore =  consensusStructs.treeStruct.maxScore(i)/bestPossibleScore;
%         st.alias ='';
% 
%         st.xcorrAtBest = consensusStructs.treeStruct.maxCorCoef(i);
% %         newElement=['[', newelt ']'];
% 
%         barcodeStructsMap(newelt) = st;
%     end
% %     hcaClusterConsensusData.details.consensusStruct.barcodeStructsMap = barcodeStructsMap;
% 
% 
% 
% %% test:
% %   hcaClusterConsensusData.clusterResultStruct.barcodes = cellfun(@(x) x.stretchedBarcode,barcodeGen(consensusStructs.treeStruct.barMatrix{idx})','UniformOutput',false);
% %     hcaClusterConsensusData.clusterResultStruct.barcodeBitmasks = cellfun(@(x) x.stretchedrawBitmask,barcodeGen(consensusStructs.treeStruct.barMatrix{idx})','UniformOutput',false);
% %     hcaClusterConsensusData.clusterResultStruct.flipTFs = logical(consensusStructs.treeStruct.barOrientation{idx}(:,2)-1);
% %     hcaClusterConsensusData.clusterResultStruct.circShifts = consensusStructs.treeStruct.barOrientation{idx}(:,1)-1;
% %     hcaClusterConsensusData.clusterResultStruct.barcodeKeys = arrayfun(@(x) num2str(x), find(consensusStructs.treeStruct.barMatrix{idx})', 'UniformOutput', false);
% %     hcaClusterConsensusData.clusterResultStruct.alignedBarcodes = num2cell(consensusStructs.treeStruct.barcodes{idx},2);
% %     hcaClusterConsensusData.clusterResultStruct.alignedBarcodeBitmasks = num2cell(~isnan(consensusStructs.treeStruct.barcodes{idx}),2);
% 
% 
%     
% 
% bestPossibleScore = sqrt(length( inputs.barcodes{1})); 
% idd = length(inputs.barcodes); 
% i=3
% %         barcodeStructsMap()
% newelt = eltLabel(consensusStructs.treeStruct.clusteredBar{i});
% % M(newelt)=idd+1;
% % idd = idd+1;
% % structure
% st.indexWeights = sum(~isnan(consensusStructs.treeStruct.barcodes{i}));
% st.maxWeight = max(st.indexWeights);
% st.barcode = nanmean(consensusStructs.treeStruct.barcodes{i});
% % parents, TF and circshift is not compatible with the old code, since
% % we circularly shift and rotate each molecule, rather than update an
% % average
% % here we also save positions and orientations
% 
% % now in parents, we report position and orientation for each
% 
% branchLeftIdx = consensusStructs.treeStruct.clusteredBar{i}{1};
% branchRightIdx = consensusStructs.treeStruct.clusteredBar{i}{2};
% 
% posLeft = fliplr(consensusStructs.treeStruct.barOrientation{i}(1:length(branchLeftIdx),:));
% posRight = fliplr(consensusStructs.treeStruct.barOrientation{i}(length(branchLeftIdx)+1:end,:));
% posLeft = posLeft-1; % correct for first index
% posRight = posRight-1; % correct for first index & orientation index
% 
% st.parents = cell(1,2);
% st.parents{1} = [branchLeftIdx' posLeft];
% st.parents{2} = [branchRightIdx' posRight];
% 
% %         arrayfun(@(x) consensusStructs.treeStruct.clusteredBar{i}{2}.
% % barcode in the cluster, rather than for the average
% %         st.parents =  {{regexprep(num2str(consensusStructs.treeStruct.clusteredBar{i}{1}),' +',','),[0],[0]},{regexprep(num2str(consensusStructs.treeStruct.clusteredBar{i}{2}),' +',','),[0],[0]} } ;
% st.bestScore =  consensusStructs.treeStruct.maxScore(i)/bestPossibleScore;
% st.alias ='';
% 
% st.xcorrAtBest = consensusStructs.treeStruct.maxCorCoef(i);
% newElement=[newelt ];
% 
% barcodeStructsMap(newElement) = st;
% 
% % figure,plot(barcodeStructsMap(newElement).barcode)
% % hold on
% % plot(consensusStruct.barcodeStructsMap(newElement).barcode)
% 
% figure,plot(barcodeStructsMap(newElement).barcode-consensusStruct.barcodeStructsMap( keysMap(newElement)).barcode)
% figure,plot(barcodeStructsMap(newElement).indexWeights)
% hold on
% plot(consensusStruct.barcodeStructsMap( keysMap(newElement)).indexWeights)
% 
% 
% barcodeStructsMap(newElement).parents{1}
% 
% consensusStruct.barcodeStructsMap( keysMap(newElement)).parents{1}
% 
% totLen = length( inputs.barcodes{1});
% % figure,plot(barcodeStructsMap(newElement).barcode-consensusStruct.barcodeStructsMap('[7,[8,9]]').barcode)
% 
% %% test2
% % consensusStruct.barcodeStructsMap(newElement)
% % st
% % consensusStruct.clusterResultStructs.
% 
% % to test particular example, we see how barcodes can be reoriented.
% 
% % consider two (or more) barcodes (time series)
% 
% b1 = inputs.barcodes{branchLeftIdx};
% b1(~inputs.barcodeBitmasks{branchLeftIdx}) = nan;
% b2 = cell2mat(inputs.barcodes(branchRightIdx));
% b2(~cell2mat(inputs.barcodeBitmasks(branchRightIdx))) = nan;
% 
% % flipp second one. if it's union of two barcodes, we need to check what
% % was their unified barcode in the previous step, and then shift that
% % barcode..
% b2r = circshift(b2, [0,consensusStruct.barcodeStructsMap( keysMap(newElement)).parents{2}{3}]);
% if consensusStruct.barcodeStructsMap( keysMap(newElement)).parents{2}{2}
%     b2r =fliplr(b2r);
% end
% 
% b2h = b2;
% % consensusStruct.barcodeStructsMap( keysMap(newElement)).parents{1}
% if barcodeStructsMap(newElement).parents{2}(2)
%     b2h =fliplr(b2);
%     b2h = circshift(b2h, [0,barcodeStructsMap(newElement).parents{2}(3)+1]);
% else
%     b2h = circshift(b2h, [0,barcodeStructsMap(newElement).parents{2}(3)]);
% end
% 
% % 
% % avgB = nanmean([b1;b2r]);
% % avgh = nanmean([b1;b2h]);
% % 
% % figure,%plot(consensusStruct.barcodeStructsMap( keysMap(newElement)).barcode)
% % hold on
% % plot(avgB)
% % plot(avgh)
% 
% % figure,plot((~isnan(b2h)).*(~isnan(b1)))
% % nanmeanPCC = @(x,y) 1/sum((~isnan(x)).*(~isnan(y)))*(x-nanmean(x))/nanstd(x,1)*(y'-nanmean(y))/nanstd(y,1);
% nanmeanPCC = @(x,y) 1/length(x).*zscore(x,1)*zscore(y',1);
% [consensusStruct.barcodeStructsMap( keysMap(newElement)).xcorrAtBest consensusStruct.barcodeStructsMap( keysMap(newElement)).bestScore]
% 
% 
% nonnans = logical((~isnan(b2r)).*(~isnan(b1)));
% [nanmeanPCC(b2r(nonnans),b1(nonnans)) nanmeanPCC(b2r(nonnans),b1(nonnans))*sqrt(sum(nonnans))/sqrt(length(nonnans))]
% 
% nonnans = logical((~isnan(b2h)).*(~isnan(b1)));
% [ nanmeanPCC(b2h(nonnans),b1(nonnans)) nanmeanPCC(b2h(nonnans),b1(nonnans))*sqrt(sum(nonnans))/sqrt(length(nonnans))]


% 1/sum((~isnan(b1)).*(~isnan(avgB)))*(b1((~isnan(b1)).*(~isnan(avgB)))-nanmean(b1))/nanstd(b1,1)*(avgB((~isnan(b1)).*(~isnan(avgB)))'-nanmean(avgB))/nanstd(avgB,1)



%     
%     b1 = barcodeStructsMap(allKeys{15}).barcode;
%     bit1 = barcodeStructsMap(allKeys{15}).indexWeights>0;
% 
%     b2 = barcodeStructsMap(allKeys{20}).barcode;
%     bit2 = barcodeStructsMap(allKeys{20}).indexWeights>0;
% 
% btest = consensusStruct.barcodeStructsMap(allKeys{20}).barcode;
% bbit = consensusStruct.barcodeStructsMap(allKeys{20}).indexWeights>0;
% 
% % if this gives 1 it's okay, they are just circ shifted. 
% 	import SignalRegistration.masked_pcc_corr;
%  [ xcorrs, numElts ] = masked_pcc_corr(b2,btest,bit2,bbit);
% 
%     [ xcorrs, numElts ] = masked_pcc_corr(b1,b2,bit1,bit2);
%     1-max(xcorrs(:))
% 
%     
% [ xcorrs, numElts ] = masked_pcc_corr(b1,btest,bit1,bbit);
% 1-max(xcorrs(:))
% 
%     
%  barcodeStructsMap(keysMap(newelt))
%  consensusStruct.barcodeStructsMap(keysMap(newelt))
% 
%      barcodeStructsMap(keysMap(newelt)).parents{1}
%      barcodeStructsMap(keysMap(newelt)).parents{2}
% 
% 
% consensusStruct.barcodeStructsMap(keysMap(newelt)).parents{1}
% consensusStruct.barcodeStructsMap(keysMap(newelt)).parents{2}


%% generate
% 
% %%
% idx=9;
% i1=round(consensusStruct.consensusMergingTree(idx,1));
% i2=round(consensusStruct.consensusMergingTree(idx,2));
% 
% b1 = barcodeStructsMap(allKeys{i1}).barcode;
% bit1 = barcodeStructsMap(allKeys{i1}).indexWeights>0;
% b2 = barcodeStructsMap(allKeys{i2}).barcode;
% bit2 = barcodeStructsMap(allKeys{i2}).indexWeights>0;
% 
% import SignalRegistration.masked_pcc_corr;
% [ xcorrs, numElts ] = masked_pcc_corr(b1,b2,bit1,bit2);
% scores = xcorrs.*sqrt(numElts)/sqrt(length(inputs.barcodes{1}));
% 1-max(scores(:))
%     
% 
% %%
% idx=9;
% i1=round(cStruct.consensusMergingTree(idx,1));
% i2=round(cStruct.consensusMergingTree(idx,2));
% 
% b1 = barcodeStructsMap(allKeys{i1}).barcode;
% bit1 = barcodeStructsMap(allKeys{i1}).indexWeights>0;
% b2 = barcodeStructsMap(allKeys{i2}).barcode;
% bit2 = barcodeStructsMap(allKeys{i2}).indexWeights>0;
% 
% import SignalRegistration.masked_pcc_corr;
% [ xcorrs, numElts ] = masked_pcc_corr(b1,b2,bit1,bit2);
% scores = xcorrs.*sqrt(numElts)/sqrt(length(inputs.barcodes{1}));
% 1-max(scores(:))
% %%
% % 
% % btest = consensusStruct.barcodeStructsMap(allKeys{20}).barcode;
% % bbit = consensusStruct.barcodeStructsMap(allKeys{20}).indexWeights>0;
% 
% % if this gives 1 it's okay, they are just circ shifted. 
% 	import SignalRegistration.masked_pcc_corr;
%  [ xcorrs, numElts ] = masked_pcc_corr(b2,btest,bit2,bbit);
% 
% %% will look at particular barcodes to see why we don't get the same score..
% 
% bars=arrayfun(@(x) find(consensusStructs.treeStruct.barToAverage{9}(x,:)),1:size(consensusStructs.treeStruct.barToAverage{9}),'un',false)';
% 1-consensusStructs.treeStruct.scoreMat{9}/sqrt(length(inputs.barcodes{1}))
% 
% b2New=nanmean(consensusStructs.treeStruct.barcodes{8});
% figure,plot(b2New-b2)
% % hold on
% % plot(b2)
end