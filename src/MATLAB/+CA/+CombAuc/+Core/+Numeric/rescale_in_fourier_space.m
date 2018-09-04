function [ interpolatedData ] = rescale_in_fourier_space( inputData,newMean, newVar )
    % 01/12/16
    % Interpolated data  to newLength + keeps normalization
 
    newB =inputData;
    
    len1 = length(inputData);
    
    newB(1) = newMean*len1;     

    %figure, plot(newB)
    
    % the sums a and b have to be the same
    a = (newVar+newMean.^2)*length(inputData);
    b = sum(newB.^2)/length(inputData);


    % if they are not the same, we renormalise intVal values 2:end by
    % constant konst
    konst=sqrt(((newVar+newMean.^2)*length(inputData).^2-newB(1).^2)/(sum(newB.^2)-newB(1).^2));

       
%          % the sums a and b have to be the same
%         a = sum(prFFT.^2)/length(prFFT);
%         b = sum(newB.^2)*length(prFFT)/(maxL.^2);
%         
%         lengthFactor=maxL.^2/(length(prFFT).^2);
% 
%         % if they are not the same, we renormalise intVal values 2:end by
%         % constant konst
%         konst=sqrt(( sum(prFFT.^2)*lengthFactor-newB(1).^2)/(sum(newB.^2)-newB(1).^2));

        
%     len2
%     a
%     newB(1).^2
%     (len2*a-newB(1).^2)
   % (len2*b-newB(1).^2)
    % and define intValNorm
    interpolatedData = abs([newB(1) newB(2:end).*konst]);
  %  interpolatedData
  %  a = sum(inputData.^2)/(len1)
  %  b = sum(interpolatedData.^2)/(len2)
    %sum(abs(interpolatedData).^2)/(len2)
    %newB(1)
end





