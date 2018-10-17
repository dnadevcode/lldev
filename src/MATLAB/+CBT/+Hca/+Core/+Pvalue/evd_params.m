function [ evdParams, rSq, cc ] = evd_params( lenShort, lenLong, filtPar, stretchFactors )
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
    %randCuts = randi(lenLong-ceil(lenShort*stretchFactors(end))+1,1,1000);
    
    coefs =cell(1,length(stretchFactors));
    parfor j=1:length(stretchFactors)
        barC = interp1(randBarcode, linspace(1,lenShort,lenShort*stretchFactors(j)));
        [xcorrs,~,~] =  CA.CombAuc.Core.Comparison.get_cc_fft(barC,refBarcode,ones(1,length(barC)),refBitmask);
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

