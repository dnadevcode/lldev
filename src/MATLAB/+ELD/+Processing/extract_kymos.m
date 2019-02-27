function [ kymos, background, kymosAmp ] = extract_kymos( channelLabeling,rotatedMovie,rotatedAmp )
    channels = cell(1,length(channelLabeling));
    kymos = cell(1,length(channelLabeling));
    kymosAmp = cell(1,length(channelLabeling));
    background = cell(1,length(channelLabeling));
    
    for i=1:length(channelLabeling)
        channels{i} = permute(rotatedMovie(find(channelLabeling{i}),:,:),[3, 2, 1]);
        kymos{i} =uint16(mean(channels{i},3));

        channelAmp = permute(rotatedAmp(find(channelLabeling{i}),:,:),[3, 2, 1]);
        kymosAmp{i} = mean(channelAmp,3);
        
        backChannels = permute(rotatedMovie(find(~channelLabeling{i}),:,:),[3, 2, 1]);
        background{i} = uint16(mean(backChannels,3));

%         fold = strcat([ff num2str(i) '.tiff']);
%         imwrite(im2uint16(kymos{i}),fold);
%         
%         fold = strcat([ff num2str(i) 'background.tiff']);
%         imwrite(im2uint16(background{i}),fold);
    end
    

end

