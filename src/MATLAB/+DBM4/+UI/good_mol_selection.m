function [allKymos,info] = good_mol_selection(numImages,kymoStructs,info)
    %   Args:
    %   numImages - array of number of images to display in x and y ,
    %   fold - folder with input images
    %   foldOut - output for folders good and bad molecules,foldOut
    %
    %   Saves all good files into good folder, bad into bad folder
    
%     import Microscopy.UI.UserSelection.select_image;

    kymoInitial = kymoStructs(info.acceptedBars);
    
    if nargin< 1
        numImages = [4 4]; % grid for images
    end

%     if nargin < 2
%         % folder with images to classify
%         fold = uigetdir(pwd, "Folder with tifs we want to classify");
%     end


%     if nargin < 3
%         % folder with images to classify
%         foldOut = uigetdir(pwd,"Select output folder");
%     end

    numImagesToShow = numImages(1)*numImages(2);

%     listing = [dir(fullfile(fold,'*.png'));dir(fullfile(fold,'*.tif'))];

%     tiffs = {listing(:).name};
%     folds = {listing(:).folder};
%     files = cellfun(@(x,y) fullfile(x,y),folds,tiffs,'UniformOutput',false);
%     
%     i=1;
    selected = [];
    for i=1:numImagesToShow:length(kymoInitial)-numImagesToShow+1
       selected = [selected; (i-1)+select_image(kymoInitial,i,numImages(1),numImages(2))]; 
    end
    iLast = i+numImagesToShow;
    if isempty(i)
        iLast = 1;
    end
    if (iLast< length(kymoInitial))
        selected = [selected; iLast-1+select_image(kymoInitial,iLast,numImages(1),numImages(2))]; 
    end
    
    allKymos = zeros(1,length(kymoInitial));
    allKymos(selected) = 1;

    info.acceptedBarsCorrected = info.acceptedBars(selected);

%     mkdir(foldOut,'good');
%     mkdir(foldOut,'bad');
%     % delete(fullfile(foldOut,'good/','*.tif'));
%     % delete(fullfile(foldOut,'bad/','*.tif'));
%     % 
%     for i = 1:length(files)
%         if allKymos(i) == 1
%             copyfile(files{i},fullfile(foldOut,'good/',tiffs{i}))
%         else
%             copyfile(files{i},fullfile(foldOut,'bad/',tiffs{i}))
%         end
%     end


end


function varargout = select_image(tiffs,ii,dim1,dim2)
    h=figure('CloseRequestFcn',@my_closereq)
    iiSt = 1;

    try
        h1 = [];
        for idx = 1:dim1
            for jdx = 1:dim2
                subplot(dim1,dim2,iiSt);
                h1(iiSt) = imshowpair(tiffs{iiSt+ii-1}.unalignedBitmask,tiffs{iiSt+ii-1}.unalignedKymo,'ColorChannels','red-cyan');
                colormap gray

                set(h1(iiSt), 'buttondownfcn', {@loads_of_stuff,iiSt+ii-1});
                iiSt = iiSt+1;
            end
        end
    catch
    end
    uiwait()
    

    function loads_of_stuff(src,eventdata,x)
        if get(src,'UserData')
            set(src,'UserData',0)
            title('');
        else
            set(src,'UserData',1)
            title('Selected');
        end
%         fprintf('%s\n',num2str(x));
%         C = get(h, 'UserData')
    
    end
%     
function my_closereq(src,callbackdata)
% Close request function 
% to display a question dialog box 
    try
    varargout{1} = find(cellfun(@(x) ~isempty(x),get(h1,'Userdata')));
    catch
    end
    delete(h)
%     uiresume() 

end

end

