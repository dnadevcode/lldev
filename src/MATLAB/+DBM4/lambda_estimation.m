function [EX,STD] = lambda_estimation(A)


%   Args:
    % A - image data
    
    % todo: include 
%% todo: MLE for two parameters

    % Sort data
    intensityVec =double(A(:));
    sortI = sort(intensityVec);
    m = numel(sortI);

    % parameter estimates
    r = 20; % gain/adFactor
    adFactor = 1; % ignore for now
    countOffset = 98; % offset / camera bias
    roNoise = 1.5; % noise std

    % r = gain/adFactor;

    lamGuess = abs((sortI(round(m/2)) - countOffset)/r);


    STD = sqrt(roNoise^2 + 2*lamGuess*r^2 + 1/12);  
    numstds = 6;
    EX = lamGuess*r/adFactor+countOffset;
%     EX
    L = EX-numstds*STD; % mean - 6 std
    U = EX+numstds*STD;

    [pdfEmccd,cdfEmccd,L,U] = pdf_cdf_emccd(ceil(L):floor(U),lamGuess,r,adFactor,countOffset,roNoise);

%     figure,plot(ceil(L):floor(U),pdfEmccd)
%     hold on
%     histogram(sortI,'Normalization','pdf')

    

    opt = statset('MaxIter',200,'MaxFunEvals',400,'FunValCheck','on');

    logL = @(data,lambda) log_likelihood_trunc_dist(data , lambda , ...
                       r, 1, countOffset, roNoise); 
                   
   N = 1000;
   Ntrials  =floor(length(sortI)/N);
   pos   = randperm(length(sortI));
   datvals = cell(1,Ntrials);
   j = 1;
    mVecTemp = sortI(pos((j-1)*(N)+1:j*N));
% %         varVecTemp = sortI(pos((j-1)*(N)+1:j*N));
%     datvals{j} =  arrayfun(@(x) logL(mVecTemp,x),10:1:45);
            
%     for j=1:Ntrials
%         j
%         mVecTemp = sortI(pos((j-1)*(N)+1:j*N));
% %         varVecTemp = sortI(pos((j-1)*(N)+1:j*N));
%             datvals{j} =  arrayfun(@(x) logL(mVecTemp,x),10:1:45);
% 
%     end
    
%     dat =  arrayfun(@(x) logL(sortI,x),35:0.1:45);

                   
    [params,pci] = mle(mVecTemp,'logpdf',logL,'start',[lamGuess],'lowerBound',[0],'Options',opt);

    lambdaBg = params(1);
    %     plot_res(sortI,params,r,adFactor,roNoise,countOffset);
    STD = sqrt(roNoise^2 + 2*lambdaBg*r^2 + 1/12);  
    EX = lambdaBg*r+countOffset;
    
       % Specify likelihood function
%     logL = @(data,lambda,r,roNoise) log_likelihood_trunc_dist(data , lambda , ...
%                        r, 1, countOffset, roNoise); 
% 
%                    
%     [params,pci] = mle(sortI,'logpdf',logL,'start',[lamGuess r roNoise],'lowerBound',[0 0 0 ],'Options',opt);

    %%
%     lambdaBg = params(1);
%     gainBg = params(2);
%     roNoiseBg = params(3); 
%     % adFactorBg = params(4);
%     r = gainBg/adFactor;
% 
%     STD = sqrt(roNoiseBg^2 + 2*lambdaBg*r^2 + 1/12);  
%     numstds = 6;
%     EX = lambdaBg*gainBg/adFactor+countOffset;
%     EX
%     L = EX-numstds*STD; % mean - 6 std
%     U = EX+numstds*STD;
% 
%     [pdfEmccd,cdfEmccd,L,U] = pdf_cdf_emccd(ceil(L):floor(U),lambdaBg,gainBg,adFactor,countOffset,roNoiseBg);
% 
%     figure,plot(ceil(L):floor(U),pdfEmccd)
%     hold on
%     histogram(sortI,'Normalization','pdf')
%     %% p-values
%     % now calc.
%     [pdfEmccd,cdfEmccd,L,U] = pdf_cdf_emccd(sortI',lambdaBg,gainBg,adFactor,countOffset,roNoiseBg);
% 
%     cdfEmccd(sortI>floor(U)) = 1;
% 
%     pvals = 1-cdfEmccd;


end


function plot_res(sortI,params,gain,adFactor,roNoise,countOffset)
    %%
    lambdaBg = params(1);
%     gainBg = params(2);
%     roNoiseBg = params(3); 
    % adFactorBg = params(4);
    r = gain/adFactor;

    STD = sqrt(roNoise^2 + 2*lambdaBg*r^2 + 1/12);  
    numstds = 6;
    EX = lambdaBg*r+countOffset;
    EX
    L = EX-numstds*STD; % mean - 6 std
    U = EX+numstds*STD;

    [pdfEmccd,cdfEmccd,L,U] = pdf_cdf_emccd(ceil(L):floor(U),lambdaBg,r,adFactor,countOffset,roNoise);

    figure,plot(ceil(L):floor(U),pdfEmccd)
    hold on
    histogram(sortI,'Normalization','pdf')


end

function [logL] = log_likelihood_trunc_dist(sortTruncI,lambda,...
                             gain, adFactor, countOffset, roNoise)

    % Calculates the  log-likelihood for the truncated EMCCD distribution . 
    % 
    % Input: 
    % 
    % sortTruncI = sorted and truncated intensity values 
    % lambda = Poisson parameter
    % chipPars = struct containing the chip parameters
    % N = number of integration points when calculating PDF 
    %     through numerical inverse Fourier-transform
    %     of the characteristic function 
    %
    % Output:
    % 
    % logL = log likelihood
    %
    % Comment: 
    % The truncated PDF is
    %      PDF_trunc = pdfEmccd(I)/cdfEmccd(I_trunc) for I <= I_trunc
    %      PDF_trunc = 0 elsewhere
    % Here, I_trunc is the truncation intensity.
    %  
    % Dependencies: emccd_distribution/pdf_cdf_emccd.m
    %
    r = gain/adFactor;

        % Analytic expressions for the mean and variance
    EX = lambda*r+countOffset; 
    STD = sqrt(roNoise^2 + 2*lambda*r^2 + 1/12);  
    
    % Analytic expression for the characteristic function 
    % for the EMCCD distribution
%     cfAnaly = @(t) exp(-t.^2*roNoise^2/2 + lambda./(1-1i*r*t) - lambda + 1i*t*offset)*2*sin(t/2)/t;

    %
   % limits where pdf is nonzero
    numstds = 6;
    L = EX-numstds*STD; % mean - 6 std
    U = EX+numstds*STD;
    
%     U = min(max(sortTruncI),U); % limit to U for truncated case

    
    % Hard-coded variable
    binWidth = 1;     % if this parameter is = 1 and the intensities are integers, 
                      % then the log-likelihood calculation is exact.
                     
    % Get bin edges
    binEdges = ceil(L):binWidth:floor(U);
%     binEdges = min(sortTruncI)-binWidth/2:binWidth:max(sortTruncI) - binWidth/2;
%     binEdges = [binEdges , max(sortTruncI) + binWidth/2];   
    histAll = histcounts(sortTruncI,binEdges)';
    binPos = binEdges(1:end-1) + diff(binEdges)/2;
   
    [pdfEmccd,cdfEmccd] = pdf_cdf_emccd(binPos,lambda,gain, adFactor, countOffset, roNoise,L,U);

%     [pdfEmccd,cdfEmccd] = pdf_cdf_emccd(binPos,lambda,chipPars,N);
    
    [~ ,cdfEmccdEnd] = pdf_cdf_emccd(min(binEdges(end),max(sortTruncI)+1),lambda,gain, adFactor, countOffset, roNoise,L,U);
%     [~ ,cdfEmccdStart] = pdf_cdf_emccd(30,lambda,gain, adFactor, countOffset, roNoise,L,U);

    % log-likelihood
    logL = sum(histAll.*log(pdfEmccd)) - sum(histAll)*log(cdfEmccdEnd);
    
 
  
end



function [pdfEmccd,cdfEmccd,L,U] = pdf_cdf_emccd(intensities,lambda,gain,adFactor,offset,roNoise,L,U)

    % Generates EMCCD probability density function (PDF) and 
    % cumulative distribution functin (CDF) by numerical inversion 
    % of the characteristic function.
    %
    % Input:
    % 
    % intensities = vector (or matrix) with intensity values
    % lambda = Poisson parameter
    % chipPars = struct containing the chip parameters
    % N = number of integration points.
    %
    % Output:
    % 
    % pdfEmccd = EMCCD probability density function 
    % cdfEmccd = cumulative distribution function 
    %
    % Refs: V. Witkovský, "Numerical inversion of a characteristic function: 
    % An alternative tool to form the probability distribution of 
    % output quantity in linear measurement models.", 
    % Acta IMEKO 5.3 (2016): 32-44, see Eqs. (8) and (9).
    %
    %

%     

    
    % Hard-coded variables:
%     pdfMin = 1E-14;   % smallest allow value for PDF 
                      % (need to be > 0 to avoid errors in 
                      % log-likelihood calculations)
%     cdfDelta = 1E-14; % smallest allowed CDF value is cdfDelta,
                      % and largest allowed CDF value is 1-cdfDelta.
      
     % Extract chip parameters
%     gain = chipPars.gain;
%     adFactor = chipPars.adFactor;
%     offset = chipPars.countOffset;
%     roNoise = chipPars.roNoise;
    r = gain/adFactor;
    

      
%     % Analytic expressions for the mean and variance
    EX = lambda*r+offset; 
    
    if nargin < 7
        STD = sqrt(roNoise^2 + 2*lambda*r^2 + 1/12);  
        numstds = 6;
        L = EX-numstds*STD; % mean - 6 std
        U = EX+numstds*STD;
    end
%     STD = sqrt(roNoise^2 + 2*lambda*r^2 + 1/12);  
%     
%     % Analytic expression for the characteristic function 
%     % for the EMCCD distribution
% %     cfAnaly = @(t) exp(-t.^2*roNoise^2/2 + lambda./(1-1i*r*t) - lambda + 1i*t*offset)*2*sin(t/2)/t;
% 
%     %
%    % limits where pdf is nonzero
%     numstds = 6;
%     L = EX-numstds*STD; % mean - 6 std
%     U = EX+numstds*STD;
%     U = min(max(intensities),U); % limit to U for truncated case


	% optimal value for step parameter
    dt = 2*pi/(U-L);

    % For discrete, integral is -pi..pi, because the output variable is
    % discretized
    N = pi/dt;
    
    
    % Estimate step size, dt, for numerical integration
    t = (1:1:N)' * dt;  

    cf = char_fun(t , roNoise,lambda,r,offset);

        % y is the grid for our pdf (from L to U)
    y = intensities;
    
    
    % calculate main integral
    pdfEmccd = trapezoidal_pdf(y,dt,t,cf);
    cdfEmccd = trapezoidal_cdf(y,dt,t,cf,EX);

   
    
end


function cfCombined = char_fun(t , roNoise,lambda,r,offset)
%

    cfAnaly = exp(-t.^2*roNoise^2/2 + lambda./(1-1i*r*t) - lambda + 1i*t*offset);
    cfROUND = 2*sin(t/2)./t;
    cfROUND(t==0) = 1;


    
    cfCombined = cfAnaly.*cfROUND;

end

%
function pdf = trapezoidal_pdf(y,dt,t,cf)
    w = ones(length(t),1);
    w(end) = 1/2; % last coef is 1/2
       
    pdf = dt/pi*(1/2 +cos(t*y)'*(real(cf).*w)+sin(t*y)'*(imag(cf).*w));
end
%
function cdf = trapezoidal_cdf(y,dt,t,cf,ex)
    w = ones(length(t),1);
    w(end)=1/2; % last coef is 1/2
    cdf = 1/2 - dt/pi*(1/2*(ex-y') +cos(t*y)'*(imag(cf./t).*w)-sin(t*y)'*(real(cf./t).*w));
end

