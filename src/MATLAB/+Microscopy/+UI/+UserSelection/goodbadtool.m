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
    selectButton = uicontrol('Parent', htab, 'Style', 'pushbutton','String',{'Select all'},'Callback',@select_all,'Units', 'normal', 'Position', [0.3 0.0 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]

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
    iiCur = iiSt;
  
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
        
        numRun = 0;
        goodBadSession.selected = zeros(numRuns,  length(files));

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
    %h1 = [];
    if numRun >= 1 && transfer
        copy_files_fold(find(goodBadSession.selected(numRun,:) == 1),files, tiffs, foldOut,'good');
        copy_files_fold(find(goodBadSession.selected(numRun,:) == -1),files, tiffs, foldOut,'bad');
        try
            copy_files_fold(find(goodBadSession.selected(numRun,:) == 1),filesTiff, tiffsTiff, foldOut,'goodKymos');
            copy_files_fold(find(goodBadSession.selected(numRun,:) == -1),filesTiff, tiffsTiff, foldOut,'badKymos');
        catch
        end
    end

    if numRun < numRuns
        numRun = numRun+1;    
        runName = ['Run\_',num2str(numRun),'\_from\_',num2str(numRuns)];
        title(hPanelRawKymosTile,runName);

        runButton.String = {['Finish run ', num2str(numRun)]}; % update run button

        for nidx = 1:numImages(1)
            for njdx = 1:numImages(2)
                tile{nidx}{njdx}.Title.String = [];
                cla(tile{nidx}{njdx});
            end
        end

        iiCur = iiSt;
        for nidx = 1:sets.numImages(1)
            for njdx = 1:sets.numImages(2)
                if iiSt <= length(files)
                    goodBadSession.selected(numRun,iiSt) = -1;
                    im{nidx}{njdx} = imagesc(tile{nidx}{njdx} ,imread(sets.files{iiSt+sets.ii-1}));
                    colormap gray                           
                    set(im{nidx}{njdx}, 'buttondownfcn', {@loads_of_stuff,iiSt+sets.ii-1,nidx,njdx});
                    iiSt = iiSt+1;
%                     tile{nidx}{njdx}.Visible = 'on';
                else
                      iiSt = length(files)+1;
                      tile{nidx}{njdx}.Visible='off';
%                       break;

%                     tile{nidx}{njdx}.Visible = 'off';
                end
            end
        end

    else
        disp('No more kymos to run. Finishing analysis')
        summary_data()
        uiresume()
    end

end


    function select_all(src, event)
        % select_all - select/deselect all elements
        iiTemp = iiCur;
        for idx1 = 1:sets.numImages(1)
            for jdx1 = 1:sets.numImages(2)
                if iiTemp <= length(files)
                    if goodBadSession.selected(numRun,iiTemp) == -1
                        tile{idx1}{jdx1}.Title.String = 'Selected';
                        goodBadSession.selected(numRun,iiTemp) = 1;
                    else
                        tile{idx1}{jdx1}.Title.String = '';
                        goodBadSession.selected(numRun,iiTemp) = -1;
                    end
                    iiTemp = iiTemp+1;
                end
            end
        end
    end

    function loads_of_stuff(src,eventdata,x,idx,jdx)
        if  goodBadSession.selected(numRun,x)== 1
            goodBadSession.selected(numRun,x) = -1;
            tile{idx}{jdx}.Title.String = '';
        else
            goodBadSession.selected(numRun,x) = 1;
            tile{idx}{jdx}.Title.String = 'Selected';
        end
    end

    function summary_data(src,eventdata)
        delete( hPanelRawKymosTile)
    %     return 
                
    %     hPanelRawKymosTile = tiledlayout(htab,2,1,'TileSpacing','loose','Padding','loose');
    %     nexttile
    %     imshow( goodBadSession.selected)
    
    end

end