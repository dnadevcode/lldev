function [ allPairsList ] = find_all_pairs(vecA, ...
                                  vecB, localRadius)
    
    %
    % Takes two sorted vectors sets and returns all pairs 
    % where the different between values in the two vectors are 
    % <= localRadius
    %
    % Input:
    % 
    % vecA = sorted vector with integers >=1
    % vecB = sorted vector with integers >=1
    % localRadius = we connect two peaks in row i and row i+1
    %                     only if their distance is <= localRadius
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

        
        occVecB = zeros(1,max(max(vecB),max(vecA)) );
        occVecB(vecB) = 1:length(vecB);  % "occupation vector": 
                                % contains 0s and indices in vecB
        idxStartB = max(1,vecA(idxA) - localRadius);
        idxStopB = min(vecA(idxA) + localRadius , length(occVecB));
        idxSearchRangeB = idxStartB:idxStopB;
        potMatchesB = occVecB(idxSearchRangeB);
        foundIdxB = find(potMatchesB >= 1);
        idxB = potMatchesB(foundIdxB);
        
        for c = 1:length(foundIdxB)
            counterPairs = counterPairs + 1;
            allPairsList(1,counterPairs)=idxA;
            allPairsList(2,counterPairs)=idxB(c);
        end

    end
    % Trim off zeros
    allPairsList = allPairsList(:,1:counterPairs);
   
           
         

end

