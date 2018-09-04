function [ parameters ] = compute_distribution_parameters(data, method,x0 )
    % 04/10/16
    % This function computes distribution parameters for specified
    % distribution. Somewhat overlaps with inbuilt functions from matlab

    if nargin < 2
        method = 'gumbel';
    end
    
    if nargin <3
        x0 = [30];
    end
    
    switch method
        case 'normal' 
            parameters = fitdist(data,'Normal'); 
        case 'gumbel'
            parameters = evfit(-data);
        case 'gev'   
            parameters = fitdist(data,'GeneralizedExtremeValue'); 
        case 'exactCC'
             f = @(y) Functions.rootFunction2( y, data );
            % x0 = [10];
             
             parameters = [fsolve(f,x0,optimoptions('fsolve','Display','off'))];

        case 'functional'

            import CA.CombAuc.Core.Functions.n_fun_test;
            f = @(y) abs(n_fun_test(y,data));
             

           % x2 = fsolve(f,x0,optimoptions('fsolve','Display','off'));
           % x2 = fzero(f,x0)
            
            
            x2 = fminbnd(f,2,x0);
 
                       
            import CA.CombAuc.Core.Functions.rootN_numeric
            N2 = rootN_numeric(x2,data);
            
            parameters = [x2 N2];
        otherwise
            parameters = [];
            warning('Unexpected choice of distribution. No parameters computed')
    end
    
end

