function [bidMat, pValNew, contigLengths2,n, II, xInd ] = convert_first_item_to_last_item(pVal, pValueThresh, contigLengths, m,n)

% converts first item to last item
[xInd, yInd] = find(pVal < pValueThresh); % limit the p-value so that contigs that are "match" with certain probability would be selected
[~,~,II] = unique(xInd); % collapses to integers 1:n so the sparse matrix we consider is simpler



n = nnz(unique(xInd));

bidMat = sparse(n,m);
pValNew = sparse(n,m);
contigLengths2 = zeros(1,n);


for i=1:length(xInd)  %pval are the starting points
    contigLengths2(II(i)) =contigLengths(xInd(i));
    endingItem = yInd(i)+full(contigLengths(xInd(i)));
    if endingItem > m
        endingItem = endingItem - m;
    end
    bidMat(II(i),endingItem) = -2*log(pVal(xInd(i), yInd(i)));
    pValNew(II(i),endingItem) = pVal(xInd(i), yInd(i));
end



end

