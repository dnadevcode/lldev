function [kymos, wideKymos] = create_channel_kymos(image, peakpos, settings)
    % create_channel_kymos - create kymos for each of the channels
    
    image(image==0) = nan;
   kymos = cell(1,length(peakpos));
   wideKymos = cell(1,length(peakpos));
    
    for idx=1:length(peakpos)
        numSegsLeft = floor((settings.averagingWindowWidth-1)/2);
        numSegsRight = floor(settings.averagingWindowWidth/2);

        img = image(:,peakpos(idx)-numSegsLeft:peakpos(idx)+numSegsRight,:);
%         wideKymos{idx} = img;
        try
            wideKymos{idx} =  image(:,peakpos(idx)-numSegsLeft-settings.wide:peakpos(idx)+numSegsRight+settings.wide,:);
        catch
            wideKymos{idx} = img;
        end
        kymos{idx} = transpose(squeeze(nanmean(img,2)));
    end

end