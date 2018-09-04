function [ consensusStruct ] = generate_consensus( molStruct, sets )
    % generate_consensus is a function which finds a consensus barcode
    % based on a molecule structure, defined in molStruct, and set of
    % parameters sets, given as an input. The outpus is the consensus
    % structure, given in consensusStruct

    % input: molStruct, sets
    % output: consensusStruct

    % code by Albertas Dvirnas, 31/08/17

   % tic % time tic to see how long the consensus takes

    % number of barcodes
    numBarcodes = length(molStruct.rawBarcodes);

    % lengths of barcodes
    lengths = cellfun(@length,molStruct.rawBarcodes);

    % Future possibility: allow barcodes of different lengths as an input
    % (for example for experiments with different conditions)
    % Therefore do not force stretching

%-     commonLength = mean(lengths);
%     if std(lengths)~=0
%         import CBT.Consensus.Core.convert_barcodes_to_common_length;
%         [molStruct] = convert_barcodes_to_common_length(molStruct,
%         commonLength);
%     end
    
    % Based on the choice of normalization, normalize the barcodes
    % before putting them into the matrix
    if strcmp(sets.barcodeConsensusSettings.barcodeNormalization, 'background')
        barcodeNormalizationFunction = @(bc, bg) (bc - bg);
       % barcodeNormalizationFunction = @(x) cellfun(bcInnerFunc, x, rawBgs, 'UniformOutput', 0);
    elseif strcmp(sets.barcodeConsensusSettings.barcodeNormalization, 'bgmean')
        barcodeNormalizationFunction = @(bc, bg) ((bc - bg) / mean(bc - bg));
       % barcodeNormalizationFunction = @(x) cellfun(bcInnerFunc, x, rawBgs, 'UniformOutput', 0);
    elseif strcmp(sets.barcodeConsensusSettings.barcodeNormalization, 'zscore')
        barcodeNormalizationFunction = @(bc,bg) zscore(bc-bg);
    end


    % define barcode matrix and bitmask. The length is that of the length
    % of longest barcode. 
    rawBar = zeros(numBarcodes,max(lengths));
    rawBit = zeros(numBarcodes,max(lengths));

    for j=1:numBarcodes
        rawBar(j,1:lengths(1)) = barcodeNormalizationFunction(molStruct.rawBarcodes{j},molStruct.barcodeGen{j}.bgMeanApprox);
        rawBit(j,1:lengths(1)) = molStruct.rawBitmasks{j};
        rawBar(j,logical(~rawBit(j,:))) = 0;
    end

    % the things that are needed for the barcode comparisons are the
    % maximal coefficient matrix maxcoef, the orientation matrix or, and
    % the positional shift matris pos. 
    maxcoef = zeros(numBarcodes-1,numBarcodes-1);
    or = zeros(numBarcodes-1,numBarcodes-1);
    pos = zeros(numBarcodes-1,numBarcodes-1);

    for barcodeIdxA = 1:numBarcodes-1
        barcodeA = rawBar(barcodeIdxA,:);
        bitmaskA = rawBit(barcodeIdxA,:);
        for barcodeIdxB = barcodeIdxA+1:numBarcodes
            barcodeB = rawBar(barcodeIdxB,:);
            bitmaskB = rawBit(barcodeIdxB,:);
            import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
           % xcorrs{barcodeIdxA,barcodeIdxB-1} = get_no_crop_lin_circ_xcorrs(barcodeA,barcodeB,bitmaskA,bitmaskB);
            xcorrs = get_no_crop_lin_circ_xcorrs(barcodeA,barcodeB,bitmaskA,bitmaskB);
            [f,s] = max(xcorrs);          
            [ b, ix ] = sort( f(:), 'descend' );
            maxcoef(barcodeIdxA,barcodeIdxB-1) = b(1);
            or(barcodeIdxA,barcodeIdxB-1) =s(ix(1));

            if s(ix(1)) == 1
                pos(barcodeIdxA,barcodeIdxB-1) = ix(1);
            else
                pos(barcodeIdxA,barcodeIdxB-1) = ix(1)-length(barcodeA);
            end
        end     
    end

    % define new  barcode matrices that will change over time  and will
    % store the averaged barcodes
     rawBar2 = rawBar;
     rawBit2 = rawBit;

    % This matrix will store the information on which barcodes are averaged
    % in which row of the matrix which was defined a step before
     barToAverage = eye(numBarcodes,numBarcodes);
    % this keeps track on which barcodes are still not joined with
    % something
     barInd =1:numBarcodes;

    % Here we go through the barcodes until the global cluster (out of all
    % the barcodes) is computed, i.e. until we have the whole tree. 
    % Tree cutting is can be done here or left for post-processing.  
     for bb=1:numBarcodes-1
         % find which barcodes should be merged
         [consensusStruct.treeStruct.maxCorCoef(bb),I] = max(maxcoef(:));

%          if M < sets.barcodeConsensusSettings.barcodeClusterLimit
%              break;
%          end
         [I_row, I_col] = ind2sub(size(maxcoef),I);

         % we merge I_row with I_col+1.
         consensusStruct.treeStruct.clusteredBar{bb} = strcat([mat2str(find(barToAverage(I_row,:))), mat2str(find(barToAverage(I_col+1,:)))]);
         barToAverage(I_row,:) = max(barToAverage(I_row,:),barToAverage(I_col+1,:));
         
         % remove I_col+1
         rawBar2(I_col+1,:) = [];
         rawBit2(I_col+1,:) = [];

         % We need to align all the barcodes from the one that is being
         % removed
         % TODO: instead of always having I_col > I_row, choose what to
         % align based on which averaged barcode has more barcodes in it. 
         % This also would give some accuracy and speed !
        [a] = find(barToAverage(I_col+1,:));
        for i=1:length(a)
             shiftInd = pos(I_row, I_col)-1;

             if or(I_row, I_col) == 2
                rawBar(a(i),:) = fliplr(rawBar(a(i),:));
                rawBit(a(i),:) = fliplr(rawBit(a(i),:));
             else
                shiftInd = -shiftInd;
             end
            rawBar(a(i),:) = circshift(rawBar(a(i),:),[0,shiftInd]);
            rawBit(a(i),:) = circshift(rawBit(a(i),:),[0,shiftInd]);
        end

        % I_col+1 was deleted.
        barToAverage(I_col+1,:) = [];
        barInd(I_col+1) = [];


        % now we substitute I_row with this new barcode
        barcodesToAverage = rawBar(logical(barToAverage(I_row,:)),:);
        barcodesToAverage(~rawBit(logical(barToAverage(I_row,:)),:)) = nan;
        rawBar2(I_row,:) = nanmean(barcodesToAverage);
        consensusStruct.treeStruct.averagedBarcodes{bb} = barcodesToAverage;
        
        rawBit2(I_row,:) = max(rawBit(logical(barToAverage(I_row,:)),:));
        rawBar2(I_row,logical(~rawBit2(I_row,:))) = 0;
        % In case I_col+1 is not the last column, we remove it from these..
        if I_col+1 <= size(maxcoef,1)
            maxcoef(I_col+1,:) = [];
            pos(I_col+1,:) = [];
            or(I_col+1,:) = [];
        end

        % If I_col is not the first row, we remove as well
        % (Note it would change a bit if I_col or I_row could be removed -
        % now only I_col can be removed)
         maxcoef(:,I_col) = [];
         pos(:,I_col) = [];
         or(:,I_col) = [];

        for barcodeIdxA = 1:I_row-1
            barcodeA = rawBar2(barcodeIdxA,:);
            bitmaskA = rawBit2(barcodeIdxA,:);
            barcodeB = rawBar2(I_row,:);
            bitmaskB = rawBit2(I_row,:);
           % import CBT.Hca.Core.Comparison.SSD_fft;
            import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
            xcorrs = get_no_crop_lin_circ_xcorrs(barcodeA,barcodeB,bitmaskA,bitmaskB);
            [f,s] = max(xcorrs);          
            [ b, ix ] = sort( f(:), 'descend' );
            indx = b(1) ;
            maxcoef(barcodeIdxA,I_row-1) = indx;
            or(barcodeIdxA,I_row-1) =s(ix(1));

            if s(ix(1)) == 1
                pos(barcodeIdxA,I_row-1) = ix(1);
            else
                pos(barcodeIdxA,I_row-1) = ix(1)-length(barcodeA);
            end 

        end

        for barcodeIdxA = I_row+1:numBarcodes-1-bb
            barcodeA = rawBar2(I_row,:);
            bitmaskA = rawBit2(I_row,:);
            barcodeB = rawBar2(barcodeIdxA,:);
            bitmaskB = rawBit2(barcodeIdxA,:);
           % import CBT.Hca.Core.Comparison.SSD_fft;
            import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
            xcorrs = get_no_crop_lin_circ_xcorrs(barcodeA,barcodeB,bitmaskA,bitmaskB);
           % [xcorrsSSD{barcodeIdxA,barcodeIdxB},indices] = SSD_fft(barcodeA,barcodeB,bitmaskA,bitmaskB,round(length(barcodeA)/2));
            [f,s] = max(xcorrs);          
            [ b, ix ] = sort( f(:), 'descend' );
            indx = b(1) ;
            maxcoef(I_row,barcodeIdxA-1) = indx;
            or(I_row,barcodeIdxA-1) =s(ix(1));

            if s(ix(1)) == 1
                pos(I_row,barcodeIdxA-1) = ix(1);
            else
                pos(I_row,barcodeIdxA-1) = ix(1)-length(barcodeA);
            end 
        end
        consensusStruct.treeStruct.barMatrix{bb} = barToAverage;
        consensusStruct.treeStruct.treeBarcodes{bb} = rawBar2;
        consensusStruct.treeStruct.treeBitmasks{bb} = rawBit2; 


%         if size(maxcoef,1)~=size(maxcoef,2)
%             maxcoef;
%         end
     end

%     [numB,mostB] = max(sum(barToAverage'));
%     if size(mostB,2)>1
%         mostB = mostB(1);
%         numB = numB(1);
%     end
% 
%     consensusStruct.barcode = rawBar2(mostB,:);
%     consensusStruct.bitmask = rawBit2(mostB,:);

    consensusStruct.time = datetime;
  %  timePassed = toc;
%    display(strcat(['All consensuses generated in ' num2str(timePassed) ' seconds']));

    
end

