function [ features ] = ...
    generate_features_from_peak_labels(noOfFeatures, peakLocs,  ...
                           peakLabels , featureLengthThres)
    
    %
    % Takes a sets of peak positions and peak labels at different times 
    % and returns a set of features.
    %
    % Input:
    % 
    % noOfFeatures = number of features (number of peak labels)
    % peakLocs = cell array with peak positions at different times
    % peakLabels = cell array with peak labels at different times
    % lengthLengthThres = length threshold for features
    % Output:
    %
    % featuresRowsAfterThres = cell array where element i contains the rows for
    %                          feature i 
    % featuresColsAfterThres = cell array where element i contains the columns for
    %                 feature i
    %
    % Written by Tobias Ambjörnsson
    %
   
    
    featureRows = cell(1,noOfFeatures);
    featureCols = cell(1,noOfFeatures);
    
    % Loop over all time frames and assign features
    for i=1:length(peakLocs)
        
        
        peakLabelsTemp = peakLabels{i};
        peakColsTemp = peakLocs{i};
        
        
        for idx = 1:length(peakLabelsTemp)
            
            featureRowsTemp = [featureRows{peakLabelsTemp(idx)} , i];
            featureRows{peakLabelsTemp(idx)} = featureRowsTemp;
         
            featureColsTemp = [featureCols{peakLabelsTemp(idx)} , peakColsTemp(idx)];
            featureCols{peakLabelsTemp(idx)} = featureColsTemp;
            
        end  
                 
    end
    
    features = [];
    
    % Threshold based on feature length
    counter = 0;
    for featureIdx = 1:noOfFeatures

        if length(featureCols{featureIdx}) > featureLengthThres
            counter = counter + 1;
            features{counter} = [featureRows{featureIdx} ; featureCols{featureIdx}];
%             featureRowsAfterThres{counter} = featureRows{featureIdx};
%             featureColsAfterThres{counter} = featureCols{featureIdx}; 
        end
        
    end
   
    
end

