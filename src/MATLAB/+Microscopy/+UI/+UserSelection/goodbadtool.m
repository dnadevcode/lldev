function [allKymos] = goodbadtool(numImages,fold,foldOut)
    %   Args:
    %   numImages - array of number of images to display in x and y ,
    %   fold - folder with input images
    %   foldOut - output for folders good and bad molecules,foldOut
    %
    %   Saves all good files into good folder, bad into bad folder
    
    import Microscopy.UI.UserSelection.select_image;
    
    if nargin< 1
        numImages = [4 4]; % grid for images
    end

    if nargin < 2
        % folder with images to classify
        fold = uigetdir(pwd, "Folder with tifs we want to classify");
    end


    if nargin < 3
        % folder with images to classify
        foldOut = uigetdir(pwd,"Select output folder");
    end

    numImagesToShow = numImages(1)*numImages(2);

    listing = [dir(fullfile(fold,'*.png'));dir(fullfile(fold,'*.tif'))];

    tiffs = {listing(:).name};
    folds = {listing(:).folder};
    files = cellfun(@(x,y) fullfile(x,y),folds,tiffs,'UniformOutput',false);


    selected = [];
    for i=1:numImagesToShow:length(files)-numImagesToShow+1
       selected = [selected; (i-1)+select_image(files,i,numImages(1),numImages(2))]; 
    end
    iLast = i+numImagesToShow;
    selected = [selected; iLast-1+select_image(files,iLast,numImages(1),numImages(2))]; 

    allKymos = zeros(1,length(files));
    allKymos(selected) = 1;


    mkdir(foldOut,'good');
    mkdir(foldOut,'bad');
    % delete(fullfile(foldOut,'good/','*.tif'));
    % delete(fullfile(foldOut,'bad/','*.tif'));
    % 
    for i = 1:length(files)
        if allKymos(i) == 1
            copyfile(files{i},fullfile(foldOut,'good/',tiffs{i}))
        else
            copyfile(files{i},fullfile(foldOut,'bad/',tiffs{i}))
        end
    end


end

