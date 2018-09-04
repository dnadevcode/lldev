function [ optimalBid ] = contig_placement_optimal_bid( possibleValues, opIndex, bidMat, contigLengths, n, m )
    % 26/08/16
    %calculates optimal bid for the contig auction problem
    % input possibleValues, opIndex, bidMat, contigLengths, n, m
    % output optimalBid
    %import CA.*;

    powersOfTwo = 2.^(0:n-1); 
    import CA.CombAuc.Core.Cap.shift_and_remove_impossible_bids;

    [bidMatShift, ~] = shift_and_remove_impossible_bids(bidMat, opIndex, contigLengths, n );

    [xx1, yy, zz] = find(possibleValues);
    
    [~, maxInd] = max(zz);
    maxIndex = xx1(maxInd);
    maxItem = yy(maxInd);

    gg = unique(yy);
    kk = size(gg,1);
    
	n = sum(de2bi(maxIndex));
    optimalBid = zeros(n,2);
    
    for i=n:-1:1
        while (kk > 1 && possibleValues(maxIndex,maxItem)==possibleValues(maxIndex,gg(kk-1)))
            maxItem = gg(kk-1);
            kk = kk - 1;
        end
        
        if i==1      
           optimalBid(1,:) = [find(de2bi(maxIndex)) maxItem];
           break; 
        end

        [xx1, ~, ~] = find(bidMatShift(:,maxItem));
        
        for iInd=1:size(xx1,1)
            prevBidder = maxIndex-powersOfTwo(xx1(iInd)); 
            bidValue = bidMatShift(xx1(iInd), maxItem);
            
            prevInd = maxItem - contigLengths(xx1(iInd))-1;
            import CA.CombAuc.Core.Cap.trace_back_to_feasible_item;

            [ prevInd, dd ] = trace_back_to_feasible_item(prevInd, gg,kk );

            if bidValue+possibleValues(prevBidder,prevInd) == possibleValues(maxIndex,maxItem)
                optimalBid(i,:) = [xx1(iInd) maxItem];
                maxItem = prevInd;
                maxIndex = prevBidder;
                kk = dd;
                break;
            end
        end   
    end
    
    import CA.CombAuc.Core.Cap.recover_original_bid_from_shifted;

    [ optimalBid ] = recover_original_bid_from_shifted(optimalBid, opIndex,contigLengths, m );
end

