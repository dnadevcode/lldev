function [ comparisonStructure ] = on_compare_theory_to_exp_least_squares( rawBarcodes,rawBitmasks,theorBar,theorBit,sets,str)
    % on_compare_theory_to_exp
    
    % input rawBarcodes,rawBitmasks,theorBar,theorBit,sets
    % output results
 
    if nargin < 6
        str = 0;
    end
    
    % what should be the best filter size?
    filterSize = sets.filterSettings.filterSize;

    % create the rezult structure
    comparisonStructure = cell(length(rawBarcodes),1);
    
    % stretch factors
    stretchFactors = sets.barcodeConsensusSettings.stretchFactors;

    % make available to all workers.
    theorBar = parallel.pool.Constant(theorBar/mean(theorBar));
    theorBit = parallel.pool.Constant(theorBit);

    % we use the standard xcorralign function (check if can change this to
    % improve speed)
    %import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
    import CA.CombAuc.Core.Comparison.get_cc_least_squares;
    % for all the barcodes run
    for i=1:length(rawBarcodes)

        % xcorrMax stores the  maximum coefficients
        xcorrMax = zeros(1,length(stretchFactors));
        
        % rezMaz stores the results for one barcode
        rezMax = cell(1,length(stretchFactors));
        
       
        % barTested barcode to be tested
        barTested = rawBarcodes{i};
        
        % length of this barcode
        lenBarTested = length(barTested);
        
        % barBitmask - bitmask of this barcode
        barBitmask = rawBitmasks{i};
       
        % make them available to workers
        barTested = parallel.pool.Constant(barTested);
        barBitmask = parallel.pool.Constant(barBitmask);

        % run the parloop for the stretch factors
        parfor j=1:length(stretchFactors)
            
            % here interpolate both barcode and bitmask 
            barC = interp1(barTested.Value, linspace(1,lenBarTested,lenBarTested*stretchFactors(j)));
            
            % if we need to filter the barcode,
            if str==1
                barC = imgaussfilt(barC, filterSize);
            end
            
            barB = barBitmask.Value(round(linspace(1,lenBarTested,lenBarTested*stretchFactors(j))));
            
            % compute the scores.
            % here separate which barcode is the longer and which is the
            % shorter (todo: check how this works when we compare fragment
            % to fragment theory)
            if length(barC) > length(theorBar.Value)
                 [xcorrs,~,~] =  CA.CombAuc.Core.Comparison.get_cc_least_squares(theorBar.Value,barC, theorBit.Value,barB);
               % [xcorrs, ~, ~] = get_no_crop_lin_circ_xcorrs(theorBar.Value,barC, theorBit.Value,barB);
            else
                [xcorrs, ~, ~] = CA.CombAuc.Core.Comparison.get_cc_least_squares(barC, theorBar.Value, barB,theorBit.Value);
                % [xcorrs, ~, ~] = get_no_crop_lin_circ_xcorrs(barC, theorBar.Value, barB,theorBit.Value);
            end 
            
            % now find the maximum score for this stretching parameter
            xcorrMax(j) = min(xcorrs(:));
            [rezMax{j}.maxcoef,rezMax{j}.pos,rezMax{j}.or] = CA.CombAuc.UI.Helper.get_best_parameters_least_squares(xcorrs,length(barC) );
        end       
        
        % find which stretching parameter had the best score
        [~,b] = min(xcorrMax);
        
        % select the results for this best stretching parameter and output
        % them.
        comparisonStructure{i} = rezMax{b};
        comparisonStructure{i}.bestBarStretch = stretchFactors(b);
        if str==1
                barC = imgaussfilt(interp1(rawBarcodes{i}, linspace(1,length(rawBarcodes{i}),length(rawBarcodes{i})*comparisonStructure{i}.bestBarStretch)), filterSize);
                comparisonStructure{i}.bestStretchedBar = barC;
        else
           comparisonStructure{i}.bestStretchedBar = interp1(rawBarcodes{i}, linspace(1,length(rawBarcodes{i}),length(rawBarcodes{i})*comparisonStructure{i}.bestBarStretch));
        end
        comparisonStructure{i}.bestStretchedBitmask = rawBitmasks{i}(round(linspace(1,length(rawBitmasks{i}),length(rawBarcodes{i})*comparisonStructure{i}.bestBarStretch)));
    end 

end

