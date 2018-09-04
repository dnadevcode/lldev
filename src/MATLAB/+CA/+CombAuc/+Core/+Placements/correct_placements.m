function [ placed,corPl ] = correct_placements( contigItems,pValueMatrix,expBarcode, sets )
    % correct_placements
    
    % input contigItems,pValueMatrix,expBarcode, sets
    % output placed,corPl

    % find min values
    [values,indices] = min(transpose(pValueMatrix));

    % start up rezult variables
    placed = 0;
    corPl = 0;
    for iInd=1:length(values)
        
        % if passes the p-value threshold
        if values(iInd) <  sets.contigSettings.pValueThresh
            
            % add one to placed contig index
            placed = placed+1;
            
            % check if close enough
            if norm( mod(contigItems{iInd}.corPlacePxStart,length(expBarcode))-mod(indices(iInd),length(expBarcode)))<  sets.contigSettings.maxDistance
                % add one to correctly placed contig index
                corPl = corPl +1;
            end
        end
    end


end

