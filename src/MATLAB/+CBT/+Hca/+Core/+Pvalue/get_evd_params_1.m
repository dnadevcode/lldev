function [evdPar, rSquaredExact, mult, x0,par1,par2, evT,tLen,rST,ccMax, xzeros ] = get_evd_params_1(lenC,lenLong, filtPar, stretchFactors, nI, b)
     % get_evd_params_1
    tLen = lenLong*2*length(stretchFactors);
    b = 1/tLen;
    %stD = cell(1,nI);
    %ccMax = zeros(1,nI);
    rST = cell(1,nI);
    evT = cell(1,nI);
    ccMax= cell(1,nI);
    xzeros = cell(1,nI);
    %lenC = lengths(j);

    % first compute nI maximun correlation coefficients, as per standard
    parfor i=1:nI
        import CBT.Hca.Core.Pvalue.evd_params_1;
        [evT{i}, rST{i},xzeros{i}, cc] = evd_params_1(lenC, lenLong, filtPar, stretchFactors);
        % how many comparisons there are in total that we sampled from
        ccMax{i} = max(cc(:));
        
        % we compute the ration between xzeros and ccMax, alternatively
        % just look how to move the distribution
        %stD{i} = xzeros{i}/ccMax{i};
    end
    stD = cell2mat(xzeros)/cell2mat(ccMax);
    % compute means and stds for the fit
    mu = cellfun(@(x) x.mu, evT);
    st =  cellfun(@(x) x.sigma, evT);

    % compute the multiplication parameter
    mult = mean(stD);

    % find a value for which the p-value can be set to 1
    fun = @(x) 1-normcdf(x,mean(mu), mean(st)) - b;
    x0 = fzero(fun,mult);

    % estimated distribution parameters
    par1 = mean(mu);
    par2 = mean(st);
    evdPar= [par1 par2];
    rSquaredExact = mean(cell2mat(rST));


                

end

