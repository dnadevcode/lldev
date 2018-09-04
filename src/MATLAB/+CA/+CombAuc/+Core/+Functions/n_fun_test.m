function [F] = n_fun_test(x, cc)
    % 25/10/16 find n using maximum likelihood method
    
    % function for maximum likelihood stuff
    
    % size of the sample set
    % x is the value we test for, cc is the set of correlation coefficients
    
    % size of cc
    m = size(cc,1);
    
    % first calculate the value of N
    denom = (-1/m*sum(log(1+betainc(cc.^2,1/2,x/2-1)))+log(2));
    N = 1./denom;
    
    % 
    nVal = x/2-1;
    %nVal = x;
    
    %derivVals = zeros(m,1);
    
    %nn = 0:0.1:2*nVal;
    %h=nn(2)-nn(1);
 
	
	%dVal =zeros(m,1);
	h = 0.00001;
	
	dVals =zeros(m,1);
    dVals= (log(1+betainc(cc.^2,1/2,nVal+h))-log(1+betainc(cc.^2,1/2,nVal-h)))./(2*h);
    
	%for i=1:m
	%	dVal(i) = (log(1+betainc(cc(i).^2,1/2,x))-log(1+betainc(cc(i).^2,1/2,x+hh)))/hh;
	%end
	
	
	
	%figure, plot(sum(dVal))
	
    %for i=1:m
    %    uu = log(1+betainc(cc(i).^2,1/2,nn));
    %    dFCenteral=(uu(3:end)-uu(1:end-2))/(2*h);
    %    derivVals(i) = dFCenteral(round(nVal/h));
    %end
    %uu
   
    
    %term1 = (N-1)*sum(derivVals);
    term1 = (N-1)*sum(dVals);
    
    % now first comput the N value
       

    % psi function difference
    psiDif =( psi((x-1)/2)-psi((x-2)/2) );
    

    % now compute the second term
    
    term2 = m*psiDif;
    
    % finally the last term
    
    term3 =sum(log(1-cc.^2));
    
    F = term1+term2+term3; 
    
    %term1
    %term2
    %term3
    %x
    %F
    
    %x
    %F


end

