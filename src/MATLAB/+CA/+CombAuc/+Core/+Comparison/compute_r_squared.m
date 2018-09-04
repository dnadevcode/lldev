function [ rSquared ] = compute_r_squared( data, evdPar, dist )
    % 04/10/16 Computes R-squared for distribution vs data
    % currently, can choose between normal, gumbel, and gev distributions
  
    if nargin < 3
        dist = 'Gumbel';
        
        SSTot = sum((data{1}-mean(data{1})).^2);
        SSres = sum((data{1}-data{2}).^2); 
        rSquared = 1 -SSres/SSTot;
        
        return;
    end
    
   [f,x]=  hist(data,floor(sqrt(size(data,1))));
   SSTot = sum((f/trapz(x,f)-mean(f/trapz(x,f))).^2);
               
    switch dist
        case 'normal' 
            distFit = normpdf(x, evdPar.mu, evdPar.sigma);
        case 'cc' 
            distFit = (1/sqrt(pi)) * (gamma((evdPar-1)/2 )/gamma((evdPar-2)/2)) * (1-x.^2).^((evdPar-4)/2);
        case 'gumbel'
            distFit = evpdf(-x, evdPar(1), evdPar(2));
        case 'gev'   
            distFit = gevpdf(x, evdPar.k, evdPar.sigma, evdPar.mu);
        case 'exact' 
            distFit = Comparison.exact_dist_PDF(x, evdPar);
        case 'exactfull'
            import CA.CombAuc.Core.Comparison.exact_full_PDF;
            distFit = exact_full_PDF(x,evdPar);
        otherwise
            distFit = f;
            warning('Unexpected choice of distribution. Nothing computed')
    end
    
    SSres = sum((f/trapz(x,f)-distFit).^2); 
    rSquared = 1 -SSres/SSTot;
      
end

