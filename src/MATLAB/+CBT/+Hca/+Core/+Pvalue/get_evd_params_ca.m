function [evdPar, rSq,ccM ] = get_evd_params_ca(lenC,refBarcode, filtPar, stretchFactors, nI)
     % get_evd_params_1
    %tLen = lenLong*2*length(stretchFactors);
    %b = 1/tLen;
%     stD = zeros(1,nI);
%     %ccMax = zeros(1,nI);
%     rST = zeros(1,nI);
%     evT = cell(1,nI);
    %lenC = lengths(j);
    ccMax = cell(1,nI);
   % vv = 0:100:1000;
    parfor i=1:nI
%         if ismember(i,vv)
%             disp(strcat(['Computing sample cc-values for bar. nr. ',num2str(i) ' out of ' num2str(nI) ]))
%         end
        
        import CBT.Hca.Core.Pvalue.evd_params_ca;
        [ cc ] = evd_params_ca( lenC, refBarcode, filtPar, stretchFactors );
        % how many comparisons there are in total that we sampled from
        ccMax{i} = max(cc(:));
        %stD(i) = xzeros/ccMax;
    end
    
    ccM = cell2mat(ccMax);
    
    % for these, we fit a Gumbel
    import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
    evdPar = compute_distribution_parameters(ccM(:),'functional',lenC/5);

    import CA.CombAuc.Core.Comparison.compute_r_squared;
    rSq = compute_r_squared(ccM(:), evdPar, 'functional' );
    
    if rSq < 0.7
       disp('Warning, p-value method might not converge, rSq < 0.7'); 
    end

%     % compute means and stds for the fit
%     mu = cellfun(@(x) x.mu, evT);
%     st =  cellfun(@(x) x.sigma, evT);
% 
%     % compute the multiplication parameter
%     mult = mean(stD);
% 
%     % find a value for which the p-value can be set to 1
%     fun = @(x) 1-normcdf(x,mean(mu), mean(st)) - b;
%     x0 = fzero(fun,mult);
% 
%     % estimated distribution parameters
%     par1 = mean(mu);
%     par2 = mean(st);
%     evdPar= [par1 par2];
%     rSquaredExact = mean(rST);


                

end

