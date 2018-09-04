function [ optimalBid ] = recover_original_bid_from_shifted(optimalBid, opIndex,contigLengths,m )
% recovers original bid from a shifted bid.
    %rewrite by adding possibility for overlap recovery.
    
    optimalBid(:,2) = optimalBid(:,2)+opIndex-1-(optimalBid(:,2)+opIndex-1 > m)*m; %shift back, could simplify
    optimalBid =  [optimalBid(:,1), (optimalBid(:,2) - transpose(contigLengths(optimalBid(:,1)))),    optimalBid(:,2) ];
    optimalBid(:,2) = optimalBid(:,2)+(optimalBid(:,2)<=0)*m;

    optimalBid = sortrows(optimalBid,1);

end

