
function  [meanBgrounds,allBackgrounds] = load_dark_frame_means(darkFramesPaths)
   % compute darkFrames - this can be taken as an input if we're looping through 
    % images in single folder (so don't need to repeat this 136 times), but
    % for single image this is fine here
    numChannels = length(darkFramesPaths);
    meanBgrounds = cell(1,numChannels);
    allBackgrounds = [];
    for j=1:numChannels
        % dark-frame - should be precomputed if there is many images in the
        % same folder that we want to compute this for
%         channelDarkFrames = darkFramesPaths(contains(darkFramesPaths,strcat('_CH',num2str(j))));
        meanBg = double(imread(darkFramesPaths{j}{1}));
        allBackgrounds(j).fov{1}=meanBg;

        for l=2:length(darkFramesPaths{j})
            darkImage = imread(darkFramesPaths{j}{l});
            meanBg = meanBg + double(darkImage);
            allBackgrounds(j).fov{l}=double(darkImage);

        end
        meanBgrounds{j} = meanBg/length(darkFramesPaths{j}); % should be ok to divide after
    end
            

end