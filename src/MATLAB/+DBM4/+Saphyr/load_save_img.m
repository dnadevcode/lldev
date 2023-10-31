function [filename,imageData] = load_save_img(moleculeImgPath,idx,meanBgrounds)
    % load bionano  
    % 
    % Re-writen from saphyrextractiontool
    %
    %   Args:
    %       moleculeImgPath - molecule file path, idx - index of the
    %       molecule we want to analyze
    %   Returns:
    %       filename - matfile with data
    
    numChannels = length(moleculeImgPath);
%     tic
    obj  = Tiff(moleculeImgPath{1}{1});

    % bionano field of view height and width - should not change
    imageWidth = getTag(obj,'ImageWidth');
    fovHeight = 2048; % not stored in the file
    imageHeight = getTag(obj,'ImageLength');
%     toc
    % number of fields of views
    numFovs = round(imageHeight/fovHeight);
    
%     signalImage = struct();
%     %     tic % extract fields of view
%     for j=1:numChannels
%         rawImg = double(imread(moleculeImgPath{j}{idx})); % read raw image as double
% %         rawFovs{j} = cell(1,numFovs); %zeros(fovHeight, imageWidth, numFovs);
%         for i=1:numFovs
%             signalImage(j).fov{i} = rawImg((i-1)*fovHeight+1:i*fovHeight, :);
%         end
%     end

    rawImg = zeros(imageHeight,imageWidth,numFovs);
    for j=1:numChannels
        rawImg(:,:,j) = double(imread(moleculeImgPath{j}{idx})); % read raw image as double
    end
%     tirc
    fold = 'matfilestorun';
    [~,~] = mkdir(fold);
    filename = cell(1,numFovs);
    [fd,fr,fu] = fileparts(moleculeImgPath{1}{idx});
    for j=1:numFovs
        channelImg = cell(1,numChannels);
        imageData =  cell(1,numChannels);
        for i=1:numChannels % check the flow direction (should be top to bottom)
            if ~isempty(meanBgrounds)
                channelImg{i}{1} = rawImg((j-1)*fovHeight+1:j*fovHeight, :,i)-meanBgrounds{i};
            else
                channelImg{i}{1} = rawImg((j-1)*fovHeight+1:j*fovHeight, :,i);
            end
        end
        imageData{1}.IntensityInfo.firstIdx = 1; % only one frame so not really necessary        
        imageData{1}.info.channels = numChannels;
        filename{j} = fullfile(fold,[fr,'-',num2str(j),'.mat']);
        save( filename{j},'channelImg','imageData','-v6');

    end
%     tocr
 

%     tiledIm = imtile(moleculeImgPath{j}{idx},[imageWidth fovHeight]);   

%     tic
%     if nargin < 2
%         import Import.load_dark_frame_means;
%         meanBg = load_dark_frame_means(darkFramesPaths,numChannels);
%     end
%     toc
    
% move this to different fun!
%     rawImgNoiseSub = cell(1,numChannels);
%     % remove noise from images
%     for j=1:numChannels
%         for i=1:numFovs
%             rawImgNoiseSub{j}{i}{1} = rawFovs{j}{i}{1}-meanBg{j};
%             rawImgNoiseSub{j}{i}{1}(rawImgNoiseSub{j}{i}{1}<0) = 0;
%             % limit max intensity by mean+6*sigma. Maybe also keep track of
%             % places where this happens
%             maxVal = mean(rawFovs{j}{i}{1}(:))+6*std(rawFovs{j}{i}{1}(:));
%             rawImgNoiseSub{j}{i}{1}(rawImgNoiseSub{j}{i}{1}>maxVal) = maxVal;
%         end
%     end
    % would want to rotate to compare with bionano outputs.. here not
    % relevant
%                          if ismember(table.Bank(idx), [1 3])
%                 rawImgNoiseSub = imrotate(rawImgNoiseSub, 180, 'crop');
%             end
% %             end
%             rawImgs{j} = rawImg;
%             rawImgsDenoised{j} = rawImgNoiseSub;
%             % Split image into fovs
%             rawFovs{j} = BarcodeExtraction.split_image_fovs(rawImgNoiseSub);
%     end
    
end