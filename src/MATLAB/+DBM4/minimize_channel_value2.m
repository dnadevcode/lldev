function [value] = minimize_channel_value2(image, par1, par2)


%     tic
    image(image==0)=nan;
    [X,Y] = meshgrid(1:2,1:size(image,1));
%     toc
%    data = interp2(X,Y,image,repmat(103,1,size(image,1)),1:size(image,2));
%        figure,plot(data)
       
    % how many pixels to skip
%     width = 3;

%     tic
% tic
    subImage = cell(1,length(1:par2:size(image,2)-par2+1));
    indexes = par1+(1:par2:size(image,2)-par2-par1+1);
    maskVal = zeros(1,length(indexes));
    for idx=1:length(indexes)
        i = indexes(idx);
%         A = image(:,i:i+round(par2)-1);
        vals=i-floor(i)+1;
%         subImage{idx} = A(:,width:end-width+1);
        subImage{idx} = interp2(X,Y,image(:,floor(i):floor(i)+1),repmat(vals,1,size(image,1)),1:size(image,2));
        
        vals = subImage{idx}(~isnan(subImage{idx}));
        mask = subImage{idx}>graythresh(vals);   
        
        % should be intensities at these points..
        maskVal(idx)= sum(bwareafilt(logical(mask),[40 size(vals,2)]));       
    end
%      toc  
%     toc
       % based on the initial channel width, run a minimization procedure
       % here that detects the best offset and channel width, i.e. so that
       % the centers of all the detected molecules fall into this
       
       %simple minimization: consider the amount of signal within channels.
       %i.e. just compute the mean
       value = nanmean(maskVal);
%        value =  nanmean(cellfun(@(x) nanmean(x(:)),subImage));
       
end

