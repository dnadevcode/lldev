function [evdParams, maxPCCsAgainstRandBarcodes] = fit_with_zero_model(...
        barcode, ...
        bitmask, ...
        randomBarcodes, ...
        randomBitmask,...
        stretchFactors, fitModel)
%     if sameLength
%         if(stretchTF) || not(isempty(stretchFactors) | isequal(stretchFactors, 1))
%             warning('Inconsistent stretch-related parameters. Using same-length option so there won''t be stretching');
%         end
%         stretchFactors = [];
%     else
%         if not(stretchTF)
%             if not(isempty(stretchFactors) | isequal(stretchFactors, 1))
%                 warning('Inconsistent stretch-related parameters. Not stretching');
%             end
%             stretchFactors = 1;
%         end
%     end

    % Function generates an extreme value distribution of cross-correlation
    % values based on random barcodes generated with random phases in Fourier
    % space

    % Calculate maximum PCCs

    tic
    if sum(bitmask)==length(bitmask) &&  sum(randomBitmask)==length(randomBitmask)
        import CBT.ExpComparison.Core.calc_max_PCCs_against_rand_barcodes_at_stretch_factors;
        maxPCCsAgainstRandBarcodes = calc_max_PCCs_against_rand_barcodes_at_stretch_factors(barcode,randomBarcodes, stretchFactors);
    else
        import CBT.ExpComparison.Core.calc_max_PCCs_against_rand_barcodes;
        maxPCCsAgainstRandBarcodes = calc_max_PCCs_against_rand_barcodes(barcode, bitmask,randomBarcodes, randomBitmask, stretchFactors);
    end
    toc


    % here make a fit based on sets.fitModel!
    import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
    evdParams = compute_distribution_parameters(maxPCCsAgainstRandBarcodes(:),fitModel,length(randomBarcodes{1}));
    
    %---Fit a theoretical extreme value distribution to the data---
    % Calculate parameters
%     gumbelCurveBeta = std(maxPCCsAgainstRandBarcodes) * (sqrt(6)/pi());  % TODO: check if using std(ccEx, 1) over std(ccEx) is more accurate
%     gumbelCurveMu = mean(maxPCCsAgainstRandBarcodes) - gumbelCurveBeta * double(eulergamma());

    % hFig = figure('Name', 'Experiment-to-Experiment CCs Hist vs Gumbel Fit);
    % hParent = hfig;
    % hAxis = axes('Parent', hParent);
    % import CBT.ExpComparison.UI.plot_gumbel_hist;
    % plot_gumbel_hist(hAxis, maxPCCsAtRandomizations, gumbelCurveMu, gumbelCurveBeta);
end