function [ evdParams, rSq, x0, cc ] = evd_params_B( lenShort, lenLong, filtPar, stretchFactors, numI )
    % evd_params_B
    
    % input  lenShort, lenLong, filtPar, stretchFactors
    % output  evdParams, rSq, cc.
    
    % currently uses all the cc's. We don't need that if we want to improve
    % the speed of this.
    
    randBarcode = imgaussfilt(rand(1,lenShort), filtPar);
    %randBitmask = ones(1,lenShort);
    
    refBarcode = imgaussfilt(rand(1,lenLong), filtPar);
    %refBitmask = ones(1,lenLong);

    % alternatively, take 1000 random samples along and 1000 the other
    % way and compute cc for these

    randCuts = randi(lenLong-ceil(lenShort*stretchFactors(end))+1,1,numI);
    
    coefs =cell(1,length(stretchFactors));
    for j=1:length(stretchFactors)
        barC = zscore(interp1(randBarcode, linspace(1,lenShort,lenShort*stretchFactors(j))));

        reff = cell(1,numI);
        reffF = cell(1,numI);

        for i=1:numI
            reff{i} = zscore(refBarcode(randCuts(i):randCuts(i)+length(barC)-1));
            reffF{i} = fliplr(reff{i});
        end

        xc = cell(1,length(randCuts));
        for k=1:length(randCuts)
            % in this case xcorrs are simpler to compute, jus
            % sum(X*Y)/(len(X)-1)
            xc{k} = [sum(reff{k}.*barC)/(length(barC)-1) sum(reffF{k}.*barC)/(length(barC)-1)];
        end
        xcorrs = cell2mat(xc);
        coefs{j} = xcorrs(:);
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

    % make sure this converges..
    x0 = fzero(fun,max(cc(:)));

            
    if rSq < 0.9
       disp('Warning, p-value method did not converge'); 
    end

end

