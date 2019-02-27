function [peakLocsRandom , peakHeightsRandom  ]...
    = generate_randomized_peak_locs_TA( peakLocs , peakHeights,  noOfCols)

% Takes set of peak positions (and peak heightss) 
% and randomly reshuffles these (row by row)
%
% Input: 
%        peakLocs = peak locations (time-frame by time-frame)
%                   in the form of a cell array
%        peakHeights = peak heights in the form of a cell array
%        noOfCols = number of columns in the original kymograph 
% 
% Output: 
%         peakLocsRandom = randomized version of peakLocs
%

    noOfRows = length(peakLocs);
    peakLocsRandom = cell(1,noOfRows); 
    peakHeightsRandom = cell(1,noOfRows); 
    
    for rowIdx = 1:noOfRows

        noOfPeaks = length(peakLocs{rowIdx});  
        
        % draw sample (with replacement)
        peakLocsTemp = randsample(noOfCols,noOfPeaks);
        
        % sort locations
        [peakLocsSorted idx] = sort(peakLocsTemp);
        peakHeightsTemp = peakHeights{rowIdx};
        peakHeightsSorted = peakHeightsTemp(idx)';
        
        % store
        peakLocsRandom{rowIdx} = peakLocsSorted;
        peakHeightsRandom{rowIdx} = peakHeightsSorted;
        
    end
    

end