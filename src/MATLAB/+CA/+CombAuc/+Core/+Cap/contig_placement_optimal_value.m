function [maxx, bestValues, opIndex] = contig_placement_optimal_value(bidMat, contigLengths, m, n )
    % method for faster calculation of the solution to the problem
    import CA.*;
    
    maxx = 0;

    powersOfTwo = 2.^(0:n-1);
    %bidMat = sparse(bidMat); 
    opIndex = 1;
    bestValues = sparse(2^n,m);

    for startIndex=1:m; % will be 1 to m %%% explain carefully and clearly what is happening in these loops
        possibleValues = sparse(2^n,m);
        
        import CA.CombAuc.Core.Cap.shift_and_remove_impossible_bids;

        [bidMatShift, currentNonzero2] = shift_and_remove_impossible_bids(bidMat, startIndex, contigLengths, n );
        
        if nnz(currentNonzero2) ~= 0
            [bidIndex,itemIndex,~] = find(currentNonzero2); 

            itInd = unique(itemIndex);

            numElts = nnz(currentNonzero2(:,itemIndex(1)));

            possibleValues(powersOfTwo(bidIndex(1:numElts)),itemIndex(1)) = transpose(bidMatShift(bidIndex(1:numElts),itemIndex(1)));

            for index=2:length(itInd)
                possibleValues(:,itInd(index)) = possibleValues(:,itInd(index-1));
                bidElt = find(currentNonzero2(:,itInd(index)));

                for biInd=1:size(bidElt,1)
                    currentElt = bidElt(biInd);
                    prevInd = itInd(index)-contigLengths(currentElt)-1;

                    if prevInd >= itInd(1)
                        kk=1;
                        while(itInd(kk+1)< prevInd)
                            kk = kk+1;
                        end
                        prevInd = itInd(kk); 

                        [vvVec,~] = find(possibleValues(:,prevInd));
                        wasBefore = bitget(vvVec, currentElt); %bitget is costly function here, could we improve on that?
                        if isequal(wasBefore,1)
                            possibleValues(powersOfTwo(currentElt),itInd(index)) = max(possibleValues(powersOfTwo(currentElt),itInd(index)),bidMatShift(currentElt, itInd(index)));
                        else
                            vecsToUpdate = vvVec(logical(~wasBefore));
                            newVecs = vecsToUpdate+powersOfTwo(currentElt);
                            newValues = possibleValues(vecsToUpdate,prevInd)+bidMatShift(currentElt, itInd(index));
                            possibleValues(newVecs,itInd(index)) = max(possibleValues(newVecs,itInd(index)),newValues);
                            possibleValues(powersOfTwo(currentElt),itInd(index)) = max(possibleValues(powersOfTwo(currentElt),itInd(index)),bidMatShift(currentElt, itInd(index)));
                        end
                    else
                        possibleValues(powersOfTwo(currentElt),itInd(index)) = max(possibleValues(powersOfTwo(currentElt),itInd(index)),bidMatShift(currentElt, itInd(index)));
                    end
                end
            end
            xxx = max(possibleValues(:,end));

            max2 =full(xxx);
            if max2 > maxx
                maxx = max2;
                opIndex = startIndex;
                bestValues = possibleValues;
            end
        end

    end

end

