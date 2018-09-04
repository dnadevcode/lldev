function [ F ] = rootFunction2( x, cc )
% function for maximum likelihood stuff
    
    
    m = size(cc,1);
    
    C1 = 1/m*sum(log(1-cc.^2));
    
    F = -psi((x-2)/2)+C1+psi((x-1)/2); 

end

