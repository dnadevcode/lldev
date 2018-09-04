function [ interpolatedData ] = interpolate_in_fourier_space_fix( inputData, newLength )
    % 01/12/16
    % Interpolated data  to newLength + keeps normalization
    
    oldLength = length(inputData);
    
    fftPr = inputData(1:floor((end+3)/2));

    %f1 = [0:length(1:(newLength+3)/2)-1]*(1/newLength);
    f1 = [0:length(1:(newLength/2))]*(1/newLength);

    f2 = [0:length(fftPr)-1]*(1/oldLength);

    % and the Parseval's identity also needs to be satisfied
    len1 = oldLength*(oldLength-1);
    len2 = newLength*(newLength-1);
    
    newB = zeros(1, newLength);
    newB(1) = inputData(1)*newLength/oldLength;     

    newf = interp1(f2(2:end),fftPr(2:end),f1(2:end));
    %figure,plot(newf)
    
    newB(2:length(newf)+1) = newf(1:end);
    newB(newLength-(1:length(newf))+1) =  newf(1:end);
    
    %figure, plot(newB)
    % the sums a and b have to be the same
    a = sum(inputData.^2)/(len1); b = sum(newB.^2)/(len2);
  
    % if they are not the same, we renormalise intVal values 2:end by
    % constant konst
    konst=sqrt((len2*a-newB(1).^2)/(len2*b-newB(1).^2));

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





