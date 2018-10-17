function [ evdParams, rSq, x0, cc ] = evd_params_1( lenShort, lenLong, filtPar, stretchFactors )
    % evd_params_A
    
    % input  lenShort, lenLong, filtPar, stretchFactors
    % output  evdParams, rSq, cc.
    
    % currently uses all the cc's. We don't need that if we want to improve
    % the speed of this.
    bar1 = normrnd(0,1, 1, lenShort);
    randBarcode = convolve_bar(bar1,  filtPar, length(bar1) );
    %randBitmask = ones(1,lenShort);
    
    bar2 =  normrnd(0,1, 1, lenLong);
    refBarcode = convolve_bar(bar2,  filtPar, length(bar2) );
    refBitmask = ones(1,lenLong);

    % alternatively, take 1000 random samples along and 1000 the other
    % way and compute cc for these

   % randCuts = randi(lenLong-ceil(lenShort*stretchFactors(end))+1,1,numI);
    
    coefs =cell(1,length(stretchFactors));
    for j=1:length(stretchFactors)
        barC = zscore(interp1(randBarcode, linspace(1,lenShort,lenShort*stretchFactors(j))));
       % [xcorrs1, xcorrs2] =  CA.CombAuc.Core.Comparison.corcoef_fft(zscore(barC),refBarcode);
      % tic 
       [xcorrs] =  CA.CombAuc.Core.Comparison.get_corcoef_fft(barC,refBarcode,ones(1,length(barC)),refBitmask);
       % toc
         coefs{j} = [xcorrs(:)];
%         tic
%         [xcorrs,~,~] =  CA.CombAuc.Core.Comparison.get_cc_fft(barC,refBarcode,ones(1,length(barC)),refBitmask);
%         toc
%         coefs{j} = xcorrs(:);
    end
                       
    cc = cell2mat(coefs);
    
    % for these, we fit a Gaussian
    import CA.CombAuc.Core.Comparison.compute_distribution_parameters;
    evdParams = compute_distribution_parameters(cc(:),'normal',20);

    import CA.CombAuc.Core.Comparison.compute_r_squared;
    rSq = compute_r_squared(cc(:), evdParams, 'normal' );
    

    % how many comparisons there are in total that we sampled from
    tLen = lenLong*2*length(stretchFactors);
    b = 1/tLen;

    fun = @(x) 1-normcdf(x,evdParams.mu,evdParams.sigma) - b;

    % make sure this converges.. Where it should the coefficient actually
    % be?
    x0 = fzero(fun,max(cc(:)));

            
    if rSq < 0.7
       disp('Warning, p-value method might not converge, rSq < 0.7'); 
    end

end

