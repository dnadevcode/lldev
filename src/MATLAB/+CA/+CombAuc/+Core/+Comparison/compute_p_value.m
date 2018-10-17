function [ pval ] = compute_p_value( cc, evdPar, method )
% 18/10/16 computes p-value

    if nargin<3
        method = 'exact';
    end
          
    switch method
         case 'gev'
            % Using Gumbeldistribution as a null model in order to calculate
            % p-values
%             k = evdPar(1);
%             sigma = evdPar(2);
%             mu = evdPar(3);
        
            pd = makedist('Generalized Extreme Value',evdPar.k,evdPar.sigma,evdPar.mu);
            pval = 1-cdf(pd,cc);
        case 'gumbel'
            % Using Gumbeldistribution as a null model in order to calculate
            % p-values
            kappa = evdPar(1);
            beta = evdPar(2);
            pval = evcdf(-cc, kappa, beta);
        case 'exact' 
         %   digits(50);
            cc(cc< 0) = 0; % so that negative values do not give false results
         %   vpa(1-vpa(betainc(cc.^2,0.5,evdPar(1)/2-1,'upper'),100),100)
    %        pval = 1 - (0.5+0.5*(1-betainc(cc.^2,0.5,evdPar(1)/2-1,'upper'))).^evdPar(2);
            pval = 1-(0.5+vpa(0.5)*(vpa(1,100)-vpa(betainc(cc.^2,0.5,evdPar(1)/2-1,'upper'),100))).^evdPar(2);
        case 'functional' 
            cc(cc< 0) = 0; % so that negative values do not give false results
            pval = 1-(0.5+vpa(0.5)*(vpa(1,100)-vpa(betainc(cc.^2,0.5,evdPar(1)/2-1,'upper'),100))).^evdPar(2);

        case 'cc'
            pval = 0.5-0.5.*sign(cc).*betainc(cc.^2,0.5,evdPar/2-1);
        otherwise
        pval = 1;
    end
end
%
