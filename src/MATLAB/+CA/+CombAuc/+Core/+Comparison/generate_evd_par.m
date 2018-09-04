function [ ppMatrix,rSquaredExact,evdPar] = generate_evd_par( ccMax,ccMatrix,len, method )
% 21/12/16

switch method
    case 'exact'
        evdPar =  Comparison.compute_distribution_parameters(ccMax(:),'exact',len);

        rSquaredExact = Comparison.compute_r_squared(ccMax(:), evdPar, 'exactfull' );
        %Comparison.compare_distribution_to_data( ccMax(:), evdPar, 'exactfull' )


        for iNew=1:size(ccMatrix,1)
           % [ccMax,~] = Comparison.compute_correlation2(length(cutBarRescaled{iNew}), length(comparisonBarcodeRescaled),  'short', psfSigmaWidth,inputData,comparisonBarcodeRescaled);
            %[evdPar] = Comparison.evd_comparisons(ccMax(:));
            ppMatrix(iNew,:) = Comparison.compute_p_value(ccMatrix(iNew,:),evdPar,'exact'); 
        end
	case 'exact2'
        import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
        evdPar = compute_distribution_parameters(ccMax(:),'exact',len);

        import CA.CombAuc.Core.Comparison.compute_r_squared;
        rSquaredExact = compute_r_squared(ccMax(:), evdPar, 'exactfull' );
        %Comparison.compare_distribution_to_data( ccMax(:), evdPar, 'exactfull' )
        ppMatrix = [];
% 
%         for iNew=1:size(ccMatrix,1)
%            % [ccMax,~] = Comparison.compute_correlation2(length(cutBarRescaled{iNew}), length(comparisonBarcodeRescaled),  'short', psfSigmaWidth,inputData,comparisonBarcodeRescaled);
%             %[evdPar] = Comparison.evd_comparisons(ccMax(:));
%             ppMatrix(iNew,:) = Comparison.compute_p_value(ccMatrix(iNew,:),evdPar,'exact'); 
%         end    
    case 'gumbel'
         evdPar =  Comparison.compute_distribution_parameters(ccMax(:),'gumbel',len);
        rSquaredExact = Comparison.compute_r_squared(ccMax(:), evdPar, 'gumbel' );

        for iNew=1:size(ccMatrix,1)
           % [ccMax,~] = Comparison.compute_correlation2(length(cutBarRescaled{iNew}), length(comparisonBarcodeRescaled),  'short', psfSigmaWidth,inputData,comparisonBarcodeRescaled);
            %[evdPar] = Comparison.evd_comparisons(ccMax(:));
            ppMatrix(iNew,:) = Comparison.compute_p_value(ccMatrix(iNew,:),evdPar,'gumbel'); 
        end
        
	case 'gev'
         evdPar =  Comparison.compute_distribution_parameters(ccMax(:),'gev',len);
        
         rSquaredExact = Comparison.compute_r_squared(ccMax(:), evdPar, 'gev' );
    
        for iNew=1:size(ccMatrix,1)
           % [ccMax,~] = Comparison.compute_correlation2(length(cutBarRescaled{iNew}), length(comparisonBarcodeRescaled),  'short', psfSigmaWidth,inputData,comparisonBarcodeRescaled);
            %[evdPar] = Comparison.evd_comparisons(ccMax(:));
            ppMatrix(iNew,:) = Comparison.compute_p_value(ccMatrix(iNew,:),evdPar,'gev'); 
        end
   	case 'gev2'
          evdPar =  Comparison.compute_distribution_parameters(ccMax(:),'gev',len);
        
         rSquaredExact = Comparison.compute_r_squared(ccMax(:), evdPar, 'gev' );
         ppMatrix = [];
    otherwise
        [];
        
end

