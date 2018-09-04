function [meanFFTSquared, meanFFTest, means, squares] = gen_mean_fft_at_bp_res(bindingProbabilities,maxL,nInd)
    % gen_mean_fft_at_bp_res
    % There are many methods to estimate autocorr function, here we
    % implement a few of them
    
    % Would be nice to check how this behaves with respect to nyquist
    % frequency, sampling errors, biased correlation definition..

    % input  bindingProbabilities,maxL,nInd
    % output meanFFTSquared, meanFFTest, means, squares

        
    
%     if nargin < 3
%         method = 'prob';
%     end
    
   % nInd = length(bindingProbabilities);
    %nInd = 1;
   % barcodeLens = cellfun(@length, bindingProbabilities);
    
   % [maxL,~] = max(barcodeLens);
       
    meanFFTSquared = zeros(1,maxL);
    %halfL = floor(maxL/2);
 %   halfL = ceil((maxL-1)/2);
    means = cellfun(@mean,bindingProbabilities);
    squares =  cellfun(@var,bindingProbabilities);
 
    for iInd = 1:length(bindingProbabilities);
        iInd
        % first compute the absolute value of fft
        prFFT = abs(fft(bindingProbabilities{iInd}));
        %figure,plot(prFFT(2:end))
        fftPr = prFFT(1:floor((end+3)/2));

        
        % new frequencies
        f1 = [0:length(1:(maxL+1)/2)-1]*(1/maxL);
        f2 = [0:length(fftPr)-1]*(1/length(prFFT));
        
        % and the Parseval's identity also needs to be satisfied
%         len1 = length(prFFT)*(length(prFFT)-1);
%         len2 = maxL*(maxL-1);
%         
        newB = zeros(1, maxL);
        newB(1) = prFFT(1)*maxL/length(prFFT); % first identity      

        newf = interp1(f2,[fftPr(2);fftPr(2:end)],f1); % interpolated function

        %figure,plot(newf(1:100))
        newB(2:length(newf)) = newf(2:end);
        newB(maxL-(2:length(newf))+2) =  newf(2:end); % so that it is symmetric, check if this is always correct?
        
        % the sums a and b have to be the same
        a = sum(prFFT.^2)/length(prFFT);
        b = sum(newB.^2)*length(prFFT)/(maxL.^2);
        
        lengthFactor=maxL.^2/(length(prFFT).^2);

        % if they are not the same, we renormalise intVal values 2:end by
        % constant konst
        konst=sqrt(( sum(prFFT.^2)*lengthFactor-newB(1).^2)/(sum(newB.^2)-newB(1).^2));

        % and define intValNorm
        intValNorm=[newB(1) newB(2:end).*konst];

        meanFFTSquared = meanFFTSquared + (intValNorm/(sqrt(nInd))).^2;
        
    end
    
    % take the square root to get meanFFTest
    meanFFTest = sqrt(meanFFTSquared);

end