function [ bidMatShift, currentNonzero] = shift_and_remove_impossible_bids(bidMat, shiftIndex, contigLengths, n )
% shifts the bid matrix and removes inpossible bids for this case

    bidMatShift = circshift(bidMat, [0, -shiftIndex+1]); 
    
    for tt=1:n % assign 0's to impossible bids for this startIndex
        if contigLengths(tt) > 0
            bidMatShift(tt,1:contigLengths(tt)) = 0;
        end
    end

    currentNonzero = bidMatShift~=0; 


end

