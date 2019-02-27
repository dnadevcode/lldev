function [ counts ] = generate_stats_for_randomized_peak_map_TA( peakLocs, peakHeights,  ...
    noOfCols , localFluctuationWindow , noOfRandomizations, allowCrossings)
%
% Statistics for randomized kymographs
%
% Input: 
%          peakLocs = cell array with peak locations
%          peakHeights = cell array with peak heights 
%          noOfCols = number of columns in original kymograph
%          localFluctuationWindow = distance between peaks in neighbouring
%                 rows must be <= this number to be linked
%          noOfRandomization = how many times we generate randomized
%                 peak maps
%          allowCrossings = set equal to 1 (true) if features are allowed
%                           to cross, else set equal to 0 (false)
%
% 
% Output:  
%          counts = vector where the first element gives the number of
%                  features with length = 1,second element gives the number
%                  of features with length = 2, etc. The length of this
%                  vector = number of rows in kymograph.

    noOfRows = length(peakLocs);
    counts = zeros(1,noOfRows);
    
    for idx = 1:noOfRandomizations
        
        % Randomize peak positions
        import ELD.TAStuffRandomizedPeakMaps.generate_randomized_peak_locs_TA;
        [peakLocsRandom , peakHeightsRandom  ]...
            = generate_randomized_peak_locs_TA( peakLocs , peakHeights,  noOfCols);

        % Assign peak labels to each peak
        import ELD.TAStuff.assign_peak_labels_TA;
        [noOfRawFeatures peakLabels] = assign_peak_labels_TA(peakLocsRandom,peakHeightsRandom,localFluctuationWindow,allowCrossings);

        % Generate features (length threshold = 0)
        import ELD.TAStuff.generate_features_from_peak_labels
         [ featureRows , featureCols ] = ...
            generate_features_from_peak_labels( noOfRawFeatures, peakLocsRandom, peakLabels , 0 );
        noOfFeatures = length(featureRows);

        % Count how many features of length 1, how many features of length 2,
        % etc. The maximum length = number of rows in kymograph.   
        for feature = 1:length(featureRows)
            idx = length(featureRows{feature});
            counts(idx) = counts(idx) + 1;
        end
    end

end

