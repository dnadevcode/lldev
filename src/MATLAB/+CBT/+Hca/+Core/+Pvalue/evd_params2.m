function [ evdParams, rSq, cc ] = evd_params2( lenShort, lenLong, filtPar, stretchFactors )
    % evd_params
    
    % input  lenShort, lenLong, filtPar, stretchFactors
    % output  evdParams, rSq, cc.
    
    % currently uses all the cc's. We don't need that if we want to improve
    % the speed of this.
    
    randBarcode = imgaussfilt(rand(1,lenShort), filtPar);
    %randBitmask = ones(1,lenShort);
    
    refBarcode = imgaussfilt(rand(1,lenLong), filtPar);
    refBitmask = ones(1,lenLong);

    % alternatively, take 1000 random samples along and 1000 the other
    % way and compute cc for these
    numI = 100;
    randCuts = randi(lenLong-ceil(lenShort*stretchFactors(end))+1,1,numI);
    
    coefs =cell(1,length(stretchFactors));
    for j=1:length(stretchFactors)
        barC = zscore(interp1(randBarcode, linspace(1,lenShort,lenShort*stretchFactors(j))));
        xcorrs = zeros(2,length(randCuts));
        for k=1:length(randCuts)
            barK = zscore(refBarcode(randCuts(k):randCuts(k)+length(barC)-1));
            barKFl = fliplr(barK);
            xcorrs(:,k) = [sum(barK.*barC)/(length(barC)-1) sum(barKFl.*barC)/(length(barC)-1)];
        end
        coefs{j} = xcorrs(:);
    end
                       
    cc = cell2mat(coefs);
    
%     f = @(y) CA.CombAuc.Core.Functions.rootFunction2( y, cc(:) );
%     parameters =[fsolve(f,40,optimoptions('fsolve','Display','final-detailed', 'TolFun',1e-12))]
%              
             
    evdParams = CA.CombAuc.Core.Comparison.compute_distribution_parameters(cc(:),'exactCC',lenShort/5);
    rSq = CA.CombAuc.Core.Comparison.compute_r_squared(cc(:), evdParams, 'cc' );
    
    if rSq < 0.9
       disp('Warning, p-value method did not converge'); 
    end

end

