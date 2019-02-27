function [ allPairsList ] = find_all_pairs_TA(vecA, vecB, localRadius)
    
    %
    % Takes two sorted vectors sets and returns all pairs 
    % where the different between values in the two vectors are 
    % <= localRadius. Uses a binary search.
    %
    % Input:
    % 
    % vecA = sorted vector with numbers (can be real numbers)
    % vecB = sorted vector with numbers (can be real numbers)
    % localRadius = we connect two elements in vecA and vecB 
    %                     only if their distance is <= localRadius
    %
    % Output:
    %
    % allPairsList = list with all indices to all pairs 
    %                 (first row = indices in vecA, 
    %                  second row = corresponding indices in vecB) 
    %
    % Dependencies: find_in_sorted_vector.m
    %
    % Written by Tobias Ambjörnsson
    %
    
    import ELD.TAStuff.find_in_sorted_vector
    
   
    % Go through the elements in vecA one by one and find
    % matches in vec B
    N=length(vecA); 
    maxNoOfPairs = (2*localRadius+1)*length(vecA);
    allPairsList = zeros(2,maxNoOfPairs);
    counterPairs = 0;
    for idxA = 1:N
                
        if vecA(idxA) - localRadius > vecB(end) | ...
           vecA(idxA) + localRadius < vecB(1)
       
             foundIdxB = [];
             
        else           
             [b c] = find_in_sorted_vector(vecB , ...
                 [ vecA(idxA) - localRadius , vecA(idxA) + localRadius]);
             foundIdxB = b:c;
             
        end    
        
        for c = 1:length(foundIdxB)
            counterPairs = counterPairs + 1;
            allPairsList(1,counterPairs)=idxA;
            allPairsList(2,counterPairs)=foundIdxB(c);
        end

    end 
    allPairsList = allPairsList(:,1:counterPairs);
         

end

