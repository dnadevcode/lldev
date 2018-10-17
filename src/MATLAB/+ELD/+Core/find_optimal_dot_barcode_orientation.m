function [feature_positions, feature_position_variances, theoretical_dot_pos, molecule_ends, flipped, fluorophoresRemoved] = find_optimal_dot_barcode_orientation( ...
            dotPositionsTheory,molecule_ends,dotWidthsTheory,feature_positions,feature_position_variances, ...
            barcodeLength,maxNumExcludedFluorophores)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%     import dotkymoAlignment.*
    import ELD.Core.calculate_shifted_dot_positions_with_margins;
    import ELD.Core.generate_barcode_from_dot_positions;
    
    
    if length(dotWidthsTheory) == 1
        dotWidthsTheory = repmat(dotWidthsTheory,length(dotPositionsTheory),1);
    end

%     [dotPositionsTheory , ~ , molecule_ends] = calculate_shifted_dot_positions_with_margins(dotPositionsTheory,barcodeLength,molecule_ends);
    
%     molecule_ends = (molecule_ends - molecule_ends(1)) * stretchFactor;
%     dotWidthsTheory = dotWidthsTheory * stretchFactor;
      
    [feature_positions, stretchFactor] = calculate_shifted_dot_positions_with_margins(feature_positions,barcodeLength);
        
    feature_position_variances = feature_position_variances * stretchFactor^2;
    dot_barcode = generate_barcode_from_dot_positions(feature_positions,sqrt(feature_position_variances),0:0.1:barcodeLength);
    
    numTheoreticalDots = numel(dotPositionsTheory);
    
    fluorophoresRemoved = cell(1);
    fluorophoresRemoved{1} = [];
    autoCorrs = [];
    tempDotPosTheory = {dotPositionsTheory};
    tempDotWidthsTheory = {dotWidthsTheory};
    molecule_ends_recalculated = [];
    endFluorophores = [1 numTheoreticalDots];
%     firstFluorophore = 1;
%     lastFluorophore = numTheoreticalDots;
%     stretchFactor = [];
    
    for numFluorophoresRemoved = 0:maxNumExcludedFluorophores
        
        possibleFluorophoresToRemove = [1:numFluorophoresRemoved numTheoreticalDots-numFluorophoresRemoved+1:numTheoreticalDots];
        
        fluorophoresRemoveCombinations = nchoosek(possibleFluorophoresToRemove,numFluorophoresRemoved);
        if numel(fluorophoresRemoveCombinations) == 0
            fluorophoresRemoveCombinations = [];
        end
        
        for fluorophoreRemovedInd = min(1,numFluorophoresRemoved):size(fluorophoresRemoveCombinations,1)
            
            if any(fluorophoresRemoveCombinations)
                fluorophoresRemoved{end+1} = fluorophoresRemoveCombinations(fluorophoreRemovedInd,:);

                fluorophoresRemoved{end} = [0 fluorophoresRemoved{end} numTheoreticalDots+1];
                step = diff(fluorophoresRemoved{end});
                if nnz(find(step~=1)) > 1
                    fluorophoresRemoved(end) = [];
                    continue;
                else
                    [endFluorophores(end+1,2),endFluorophores(end,1)] = max(step);

%                     [tempMax,tempMin] = max(step);
%                     
%                     endFluorophores(end,1) = tempMin;
%                     endFluorophores(end+1,2) = tempMax;
                    
                    endFluorophores(end,2) = endFluorophores(end,2) + endFluorophores(end,1) - 2;
                end
                
                tempDotPosTheory{end+1} = dotPositionsTheory;
                tempDotWidthsTheory{end+1} = dotWidthsTheory;

%                 for removalIdx = fluorophoresRemoved{end}(2:end-1)
%                 for removalIdx = 1:numel(fluorophoresRemoved{end}(2:end-1))
%                     removalIdx = fluorophoresRemoved{end}(end-removalIdx);
%                     tempDotPosTheory{end}(removalIdx) = [];
%                     tempDotWidthsTheory{end}(removalIdx) = [];
%                 end
                tempDotPosTheory{end}(fluorophoresRemoved{end}(2:end-1)) = [];
                tempDotWidthsTheory{end}(fluorophoresRemoved{end}(2:end-1)) = [];
                fluorophoresRemoved{end} = fluorophoresRemoved{end}(2:end-1);
            
            end
            
            [tempDotPosTheory{end} , ~ , molecule_ends_recalculated(end+1,:)] = calculate_shifted_dot_positions_with_margins(tempDotPosTheory{end},barcodeLength,molecule_ends);
    
%             tempDotWidthsTheory{end} = tempDotWidthsTheory{end} *  numTheoreticalDots / (numTheoreticalDots-length(fluorophoresRemoved{end}));
            theoreticalDotBarcode = generate_barcode_from_dot_positions(tempDotPosTheory{end},tempDotWidthsTheory{end},0:0.1:barcodeLength);

        %     figure, plot(dot_barcode{kymo});

%             flippedBarcode = flip(dot_barcode);

            autoCorrs(end+1,1) = xcorr(theoreticalDotBarcode,dot_barcode,0);
            autoCorrs(end,2) = xcorr(theoreticalDotBarcode,flip(dot_barcode),0);
            
        end
    
    end
    
    [~,best_idx] = max(autoCorrs(:));
    [best_fluorophore_comb,best_flip] = ind2sub(size(autoCorrs),best_idx);
    
    if best_flip == 1
        flipped = false;
%         if best_idx_A == 1
%             firstFluorophore = 1;
%             lastFluorophore = numTheoreticalDots;
%         else
%             firstFluorophore = fluorophoresRemoved{best_idx_A}(1) + 1;
%             lastFluorophore = fluorophoresRemoved{best_idx_A}(end) - 1;
%         end
    else
        feature_positions = barcodeLength - flip(feature_positions);
        flipped = true;
        if best_fluorophore_comb ~= 1
            firstFluorophore_temp = numTheoreticalDots - endFluorophores(best_fluorophore_comb,2) + 1;
            endFluorophores(best_fluorophore_comb,2) = numTheoreticalDots - endFluorophores(best_fluorophore_comb,1) + 1;
            endFluorophores(best_fluorophore_comb,1) = firstFluorophore_temp;
%             firstFluorophore = 1;
%             lastFluorophore = numTheoreticalDots;
%         else
%             firstFluorophore = numTheoreticalDots - fluorophoresRemoved{best_idx_A}(end) + 2;
%             lastFluorophore = numTheoreticalDots - fluorophoresRemoved{best_idx_A}(1);
        end
    end
%     step = diff(fluorophoresRemoved{best_idx_A});
%     firstInd = find(step>1) - 1;

%     if lastFluorophore < numTheoreticalDots - length(fluorophoresRemoved{best_idx_A})
%         firstFluorophore = lastFluorophore;
%         lastFluorophore = numTheoreticalDots;
%     elseif firstFluorophore > length(fluorophoresRemoved{best_idx_A})
%         lastFluorophore = firstFluorophore;
%         firstFluorophore = 1;
%     end

    stretchFactor = (tempDotPosTheory{1}(endFluorophores(best_fluorophore_comb,2)) - tempDotPosTheory{1}(endFluorophores(best_fluorophore_comb,1))) / (tempDotPosTheory{1}(end) - tempDotPosTheory{1}(1));
    
    feature_positions = feature_positions - feature_positions(1);
    feature_positions = feature_positions * stretchFactor + tempDotPosTheory{1}(endFluorophores(best_fluorophore_comb,1));
    
%     if best_idx == 2
%         flipped = true;
% %         dot_barcode = flip(dot_barcode);
%         feature_positions = barcodeLength - feature_positions;
%         feature_position_variances = flip(feature_position_variances);
%     else
%         flipped = false;
%     end
    theoretical_dot_pos = tempDotPosTheory{1};
    molecule_ends = molecule_ends_recalculated(1,:);

end

