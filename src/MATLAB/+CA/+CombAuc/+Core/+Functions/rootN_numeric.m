function [ F ] = rootN_numeric(x,cc,method )
    % Finding N given x

    if nargin < 3
        method = 'betainc';
    end
    
    
    m = size(cc,1);
    
       
    switch method
        case 'betainc' 
            denom = (-1/m*sum(log(1+betainc(cc.^2,1/2,x/2-1)))+log(2));
            F = 1./denom;
        case 'hypergeom'
            C1 = gamma((x-1)/2)./(sqrt(pi)*gamma((x-2)/2));
            C2 = sum(log(C1.*cc.*NUMERICAL.hypergeometric2f1(1/2, (4-x)/2 ,3/2,cc.^2,10 )+1/2));
            F = -m./C2;
        otherwise
            F = 2*x;
            warning('No method selected')
    end
    
    

end

