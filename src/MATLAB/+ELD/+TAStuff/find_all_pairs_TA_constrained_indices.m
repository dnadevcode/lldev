function [ allPairsList ] = find_all_pairs_TA_constrained_indices(vecA, ...
                                  vecB, localRadius, peakIdxRadius)
    
    %
    % Takes two sorted vectors sets and returns all pairs 
    % where the different between values in the two vectors are 
    % <= localRadius
    %
    % Input:
    % 
    % vecA = sorted vector with numbers (can be real numbers)
    % vecB = sorted vector with numbers (can be real numbers)
    % localRadius = we connect two peaks in row i and row i+1
    %                     only if their distance is <= localRadius
    % peakIdxRadius  = maximum index shift between two peaks in row i and row i+1. 
    %                  When comparing a peak with index, idxParent, from row i 
    %                  to peaks, idXChildren, from row i+1, only peaks satisfying 
    %                  idxParent - peakIdxRadius <= idxChildren <= idxParent - peakIdxRadius
    %                  are considered (for speed purposes).
    %
    % Output:
    %
    % allPairsList = list with all indices to all pairs 
    %                 (first row = indices in vecA, 
    %                  second row = corresponding indices in vecB) 
    %
    % Written by Tobias Ambjörnsson
    %
   
   
    maxNoOfPairs = (2*localRadius+1)*length(vecA);
    allPairsList = zeros(2,maxNoOfPairs);
    counterPairs = 0;
    
    for idxA = 1:length(vecA) 

        idxStartB = max(1,idxA - peakIdxRadius);
        idxStopB = min(idxA + peakIdxRadius , length(vecB));
        idxSearchRangeB = idxStartB:idxStopB;
        potMatchesB = vecB(idxSearchRangeB);
        foundIdxB = find(potMatchesB >= vecA(idxA) - localRadius & ...
                              potMatchesB <= vecA(idxA) + localRadius);
        idxB = idxSearchRangeB(foundIdxB);
        
        for c = 1:length(foundIdxB)
            counterPairs = counterPairs + 1;
            allPairsList(1,counterPairs)=idxA;
            allPairsList(2,counterPairs)=idxB(c);
        end

    end
    % Trim off zeros
    allPairsList = allPairsList(:,1:counterPairs);
   
           
         

end

