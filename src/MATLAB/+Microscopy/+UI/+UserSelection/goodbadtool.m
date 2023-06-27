function [goodBadSession,kymoStatsTable] = goodbadtool(numImages, foldImgs, statsFile, foldOut, sets, hfig)
    %   Args:
    %   numImages - array of number of images to display in x and y ,
    %   fold - folder with input images
    %   foldOut - output for folders good and bad molecules,foldOut
    %
    %   Saves all good files into good folder, bad into bad folder
    
    %     import OldDBM.General.SettingsWrapper;
    %     import Core.hpfl_extract;
    
    % Kymos need to be in raw_kymo folder
    % Pngs in .png folder        
    goodBadSession  = []; % good-bad-tool session file

    if nargin < 5
        import DBM4.UI.find_default_settings_path;
        defaultSettingsFilepath = find_default_settings_path('DBMnew.ini');
        import Fancy.IO.ini2struct;
        sets = ini2struct(defaultSettingsFilepath);
    end

    if nargin < 6
    mFilePath = mfilename('fullpath');
        mfolders = split(mFilePath, {'\', '/'});
        versionLLDEV = importdata(fullfile(mfolders{1:end-6},'VERSION'));
    
        hFig = figure('Name', ['Good-bad-tool from  DBM v' versionLLDEV{1}], ...
            'Units', 'normalized', ...
            'OuterPosition', [0.05 0.1 0.8 0.8], ...
            'NumberTitle', 'off', ...     
            'MenuBar', 'none',...
            'ToolBar', 'none' ...
        );
    
        tshAdd = uitabgroup('Parent',hFig);
        htab = uitab(tshAdd, 'title',strcat('Good-bad filtering tab'));

    else
        htab = hfig.Re;
%         htab = uitab(hfig, 'title',strcat('Good-bad filtering tab'));
    end


    import Microscopy.UI.UserSelection.select_image;
    
    if nargin< 1
        numImages = [4 4]; % grid for images
    end

    if nargin < 2
        % folder with images to classify
        foldImgs = uigetdir(pwd, "Folder with images we want to classify");
    end

    if nargin < 3
        % folder with images to classify
        foldStads = uigetfile(pwd, " Provide statsfile for this run");
    end

    if nargin < 4
        % folder with images to classify
        foldOut = uigetdir(pwd,"Select output folder");
    end

    runButton = uicontrol('Parent', htab, 'Style', 'pushbutton','String',{'Run next set'},'Callback',@run_next_set,'Units', 'normal', 'Position', [0.5 0.0 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]

    hPanelRawKymosTile = tiledlayout(htab,numImages(1)+1,numImages(2),'TileSpacing','loose','Padding','loose');
    tile = [];
    for idx = 1:numImages(1)
        for jdx = 1:numImages(2)
            tile{idx}{jdx} = nexttile(hPanelRawKymosTile);
            axis off;
        end
    end
    im = cell(numImages(1),numImages(2));

    if ~isempty(foldOut)
        [~,~] = mkdir(foldOut,'good');
        [~,~] = mkdir(foldOut,'bad');
        [~,~] = mkdir(foldOut,'goodKymos');
        [~,~] = mkdir(foldOut,'badKymos');
        transfer = 1;
    else
        transfer = 0;
    end
 
    iiSt = 1;
  
%     statsFile = load(statsFile);
    numImagesToShow = numImages(1)*numImages(2);

    if ~iscell(foldImgs)
        listing = [dir(fullfile(foldImgs,'*.png'));dir(fullfile(foldImgs,'*.tif'))];
        tiffs = {listing(:).name};
        folds = {listing(:).folder};
        files = cellfun(@(x,y) fullfile(x,y),folds,tiffs,'UniformOutput',false);
        % only if ending is .png
        if isequal(tiffs{1}(end-2:end),'png')
            filesTiff = cellfun(@(x,y) strrep(strrep(fullfile(x,y),'pngs','raw_kymo'),'.png','.tif'),folds,tiffs,'UniformOutput',false);
            tiffsTiff = cellfun(@(x) strrep(x,'.png','.tif'),tiffs,'un',false);
        end
    else
        files = foldImgs;
    end
            sets.files = files;

        % sets.tiffs = tiffs;
        sets.ii = 1;
        sets.numImages = numImages;
        
        numRuns = ceil(length(files)/numImagesToShow);
        
        numRun = 1;
        for i=1:numRuns
            goodBadSession.selected = zeros(numRuns,  length(files));
        end

        run_next_set();
        uiwait();

        if ~isempty(statsFile)
            goodKymosIdx = sum(goodBadSession.selected==1);
            stats = load(statsFile);

            kymoStatsTable = stats.kymoStatsTable(find(goodKymosIdx),:);
%             kymoStatsTableBad = stats.kymoStatsTable(find(~goodKymosIdx),:);

            save(strrep(statsFile,'.mat','_goodbad.mat'),'kymoStatsTable');

        else
            kymoStatsTable = [];
        end

% copyfiles
function copy_files_fold(idxs,files, tiffs, foldOut,fold)
    for i = idxs
        copyfile(files{i},fullfile(foldOut,fold,tiffs{i}));
    end

end

function run_next_set(src, event)
    
    h1 = [];
    if numRun > 1 && transfer
        copy_files_fold(find(goodBadSession.selected(numRun,:) == 1),files, tiffs, foldOut,'good');
        copy_files_fold(find(goodBadSession.selected(numRun,:) == -1),files, tiffs, foldOut,'bad');
        try
            copy_files_fold(find(goodBadSession.selected(numRun,:) == 1),filesTiff, tiffsTiff, foldOut,'goodKymos');
            copy_files_fold(find(goodBadSession.selected(numRun,:) == -1),filesTiff, tiffsTiff, foldOut,'badKymos');
        catch
        end
    end

    if numRun <= numRuns

        title(hPanelRawKymosTile,['Run\_',num2str(numRun),'\_from\_',num2str(numRuns)]);
        numRun = numRun+1;      
        for idx = 1:numImages(1)
            for jdx = 1:numImages(2)
              tile{idx}{jdx}.Title.String = [];
%                 cla(im{idx}{jdx});
%                 delete(tile{idx}{jdx});
                cla(tile{idx}{jdx});
%                 cla(im{idx}{jdx})
%                 set(gca,'color',[0 0 0]);
%                 set(hAxis,'XTick',[]);
%                 set(hAxis,'YTick',[]);
    % 
            end
        end


        for idx = 1:sets.numImages(1)
            for jdx = 1:sets.numImages(2)
                if iiSt <= length(files)
                     goodBadSession.selected(numRun,iiSt) = -1;

%                     axes(tile{idx}{jdx})
%                     if ~ismatrix(sets.files{iiSt+sets.ii-1})
%                         nexttile
                        im{idx}{jdx} = imagesc(tile{idx}{jdx} ,imread(sets.files{iiSt+sets.ii-1}));
%                         h1(iiSt) = 
%                         tile{idx}{jdx}.
%                     else
%                         h1(iiSt) = imagesc(sets.files{iiSt+sets.ii-1});
%                     end
%                     hold on

                    colormap gray
%                     set(gca,'color',[0 0 0]);
%                     set( h1(iiSt),'XTick',[]);
%                     set( h1(iiSt),'YTick',[]);
                           
                    set(im{idx}{jdx}, 'buttondownfcn', {@loads_of_stuff,iiSt+sets.ii-1,idx,jdx});
                    iiSt = iiSt+1;
                else
                    iiSt = length(files)+1;
                end
            end
        end
    else
        disp('No more kymos to run. Finishing analysis')
        summary_data()
        uiresume()
    end

end
% 
% 
%   h=figure('CloseRequestFcn',@my_closereq)
%     iiSt = 1;
% 
%     try
%         h1 = [];
%         for idx = 1:numImages(1)
%             for jdx = 1:numImages(2)
%                 subplot(dim1,dim2,iiSt);
%                 h1(iiSt) = imagesc(imread(tiffs{iiSt+ii-1}));
%                 colormap gray
% 
%                 set(h1(iiSt), 'buttondownfcn', {@loads_of_stuff,iiSt+ii-1});
%                 iiSt = iiSt+1;
%             end
%         end
%     catch
%     end
%     
% 
    function loads_of_stuff(src,eventdata,x,idx,jdx)
        if get(src,'UserData')
            set(src,'UserData',0)
             goodBadSession.selected(numRun,x) = -1;
            tile{idx}{jdx}.Title.String = '';
%             tile{idx}{jdx}.Title.String = '';
        else
            set(src,'UserData',1)
             goodBadSession.selected(numRun,x) = 1;
            tile{idx}{jdx}.Title.String = 'Selected';

%             title(src,'Selected');
%             tile{idx}{jdx}.Title.String = 'Selected';

        end
%         fprintf('%s\n',num2str(x));
%         C = get(h, 'UserData')
    
    end
% %     
% function my_closereq(src,callbackdata)
% % Close request function 
% % to display a question dialog box 
%     try
%     varargout{1} = find(cellfun(@(x) ~isempty(x),get(h1,'Userdata')));
%     varargout{2} = find(cellfun(@(x) isempty(x),get(h1,'Userdata')));
% 
%     catch
%     end
%     delete(h)
% %     uiresume() 
% 
% end
% 
% end
% 
% end
% 
function summary_data(src,eventdata)
    delete( hPanelRawKymosTile)
%     return 
            
%     hPanelRawKymosTile = tiledlayout(htab,2,1,'TileSpacing','loose','Padding','loose');
%     nexttile
%     imshow( goodBadSession.selected)

end

end