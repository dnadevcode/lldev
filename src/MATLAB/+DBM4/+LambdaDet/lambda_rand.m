function [barRand] = lambda_rand(dbmStruct,barcodeGen,bgest,nbars,nEdge)
    % create shuffled barcodes for lambda thresh estimation
%     bgest = dbmStruct.kymoCells.threshval(acceptedBars);

    randPermIdx = datasample(1:length(barcodeGen),nbars);
    barRand = barcodeGen(randPermIdx);

    if nargin < 5
        nEdge = 20;
    end

    for i=1:length(barRand)
        barRand{i}.rawBarcode = barRand{i}.rawBarcode-bgest{randPermIdx(i)};
        barRand{i}.rawBarcode(nEdge+1:end-nEdge) = datasample(barRand{i}.rawBarcode(nEdge+1:end-nEdge),length(barRand{i}.rawBarcode(nEdge+1:end-nEdge)));
%         barRand{i}.rawBitmask = ones(1,length( barRand{i}.rawBarcode ));
    end

        % BEFORE:  too different from realistic
%         try
%         allPoints = cell2mat(cellfun(@(x,y) x.rawBarcode(x.rawBitmask)-y,barcodeGen,,'un',false));
%         if length(allPoints)<round(sets.maxLen)
%             allPoints =[ allPoints allPoints]; % duplicate if not long enough
%         end
%         randPermutationData = arrayfun(@(x) randperm(length(allPoints),round(sets.maxLen)),1:nbars,'un',false);
%         bars = cellfun(@(x) allPoints(x),randPermutationData,'un',false);
%         barRand = cell(1,length(bars));
%         for i=1:length(bars)
%             barRand{i}.rawBarcode = bars{i};
%             barRand{i}.rawBitmask = ones(1,length( barRand{i}.rawBarcode ));
%         end

end

