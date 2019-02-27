function [ featureColsShifted, comShifts ] = ...
    generate_com_corrected_features(featureRows , featureCols , noOfRows)
    %
    % Takes features at different times 
    % and returns a set of center-of-mass corrected features.
    %
    % Input:
    %
    % featuresRows = cell array where element i contains the rows for
    %                          feature i 
    % featuresCols = cell array where element i contains the columns for
    %                          feature i
    % noOfRows = number of rows in original kymograph
    %
    % Output:
    %
    % featureColsShifted = cell array where element i contains the 
    %                         center-of-mass corrected colums for feature i 
    % comShifts = average shifts in position 
    %             between linked peaks in row i and i-1 (first element = 0)
    %
    % NOTE: if an element has value 'NaN', then no feature exist for that
    %        time frame
    %
    % NOTE: center-of-mass positions = cumsum(comShifts)
    %
    % Written by Tobias Ambjörnsson
    %
     
    summedShifts = zeros(1,noOfRows);
    noOfLinkedPeaks = zeros([1,noOfRows]);
    
    % Loop over all features 
    for featureIdx=1:length(featureRows)
       
        rowTemp = featureRows{featureIdx};
        colTemp = featureCols{featureIdx};
         
        % loop over all "parent" rows which does have a "child" row 
        for idx = 1:length(rowTemp) - 1 
            
           noOfLinkedPeaks(rowTemp(idx)) = noOfLinkedPeaks(rowTemp(idx)) + 1;
           summedShifts(rowTemp(idx)) = summedShifts(rowTemp(idx)) + colTemp(idx+1) - colTemp(idx); 
         
        end
       
                 
    end   
    idxNoFeatures = find(noOfLinkedPeaks == 0);
    noOfLinkedPeaks(idxNoFeatures)=NaN;
  
    comShifts = summedShifts./noOfLinkedPeaks; 
    comShifts(2:noOfRows) =  comShifts(1:noOfRows-1);
    comShifts(1) = 0;
    
    
   % Now correct all features with the center-of-mass (com) position
    comPos = cumsum(comShifts);
   
   for featureIdx=1:length(featureRows)
           
        rowTemp = featureRows{featureIdx};
        colTemp = featureCols{featureIdx};
        
        for idx = 1:length(rowTemp) 
           
           colTemp(idx) = colTemp(idx) - comPos(rowTemp(idx));
           
        end
        featureColsShifted{featureIdx} = colTemp;
                 
    end
   
   
    
end

