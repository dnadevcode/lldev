function [] = dna_barcode_matchmaker(useGUI, dbmOSW)
    % Replicates DBM_GUI but with simplified structures
    
    %   Args:
    %       useGUI - whether to run user friendly GUI
    %       dbmOSW - nput settings
    
    dbmStruct = [];
    
    if nargin < 2
        % Get default settings path
        import OldDBM.General.SettingsWrapper;
        defaultSettingsFilepath = SettingsWrapper.get_default_newDBM_ini_filepath();
        if not(exist(defaultSettingsFilepath, 'file'))
        defaultSettingsFilepath = '';
        end
        dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);
        dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm'; 
%         dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;
%         dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;
    end
    
    
    if nargin >=1
        dbmOSW.DBMSettingsstruct.useGUI = useGUI;  
    end

    import Core.hpfl_extract;

    if dbmOSW.DBMSettingsstruct.useGUI
        % generate menu
        % https://se.mathworks.com/help/matlab/ref/uimenu.html
  
        [sets,tsHCC,textList,textListT,itemsList,...
                hHomeScreen,hPanelRawKymos,hPanelAlignedKymos,hPanelTimeAverages,hAdditional]= generate_gui();
%         show_home();

    else
        if dbmOSW.DBMSettingsstruct.auto_run     
            [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(dbmOSW.DBMSettingsstruct);

            [sets,tsHCC,textList,textListT,itemsList,...
            hHomeScreen,hPanelRawKymos,hPanelAlignedKymos,hPanelTimeAverages,hAdditional]= generate_gui();
        
            show_home();
        else
            sets = dbmOSW.DBMSettingsstruct;
        end
            
%         hFig = figure('Name', 'DNA Barcode Matchmaker', ...
%             'Units', 'normalized', ...
%             'OuterPosition', [0.05 0.1 0.8 0.8], ...
%             'NumberTitle', 'off', ...
%             'MenuBar', 'none', ...
%             'ToolBar', 'none' ...
%         );
%    
%         hPanel = uipanel('Parent', hFig);
%         h = uitabgroup('Parent',hPanel);
%         t1 = uitab(h, 'title', 'DBM');
%         tsHCC = uitabgroup('Parent',t1);
% %         hPanelImport = uitab(tsHCC, 'title', 'DBM settings');
%         hHomeScreen= uitab(tsHCC, 'title',strcat('HomeScreen'));
        
    end
    
    if dbmOSW.DBMSettingsstruct.genome_assembly_pipeline
        genome_assembly_pipeline()
        
    end
    


    function save_settings(src, event)
        
        
%             sets.folder = dotImport.String;
        sets.averagingWindowWidth = str2double(textList{1}.String);
        sets.nmPerPixel =  str2double(textList{2}.String);
        sets.rowSidePadding =  str2double( textList{3}.String);
        sets.parForNoise =   str2double(textList{4}.String);

        sets.distbetweenChannels = str2double(textList{5}.String);
        
        sets.numFrames = str2double(textList{6}.String);
        sets.max_number_of_frames =  str2double(textList{7}.String);

%         sets.movies.denoise = str2double(textList{8}.String);
        sets.timeframes = str2double(textList{8}.String);
        sets.stdDifPos  = str2double(textList{9}.String);
        sets.numPts  = str2double(textList{10}.String);
        sets.minLen  = str2double(textList{11}.String);

        sets.moleculeAngleValidation = itemsList{1}.Value;
        sets.timeframes = itemsList{2}.Value;
        sets.denoise = itemsList{3}.Value;
        sets.detectlambdas  = itemsList{4}.Value;

        
    end

    function restore_settings(src, event)
        sets =  dbmOSW.DBMSettingsstruct;
        % also uppdate values
        textList{1}.String = num2str(sets.averagingWindowWidth );
        textList{2}.String   =  num2str(sets.nmPerPixel);
        textList{3}.String  =   num2str(sets.rowSidePadding);
        textList{4}.String  =   num2str(sets.parForNoise);

        textList{5}.String   = num2str(sets.distbetweenChannels);

        textList{6}.String  =  num2str(sets.numFrames);
        textList{7}.String  =  num2str(sets.max_number_of_frames);

        %         sets.movies.denoise = str2double(textList{8}.String);
        textList{8}.String  =  num2str(sets.timeframes);
        textList{9}.String  =  num2str(sets.stdDifPos);
        textList{10}.String  =  num2str(sets.numPts);
        textList{11}.String  =  num2str(sets.minLen);

        itemsList{1}.Value =  sets.moleculeAngleValidation;
        itemsList{2}.Value = sets.timeframes;
        itemsList{3}.Value  =  sets.denoise;
        itemsList{3}.Value  =  sets.detectlambdas;

    end

    function re_run(src, event)
        
        save_settings(); % first save settigns
        
        import Core.hpfl_extract;
        [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets);

%         import Core.hpfl_odm_extract;
%         [dbmStruct.fileCells, dbmStruct.fileMoleculeCells] = hpfl_odm_extract(dbmOSW.DBMSettingsstruct);
        show_home();
    end


    function re_run_filtering(src, event)
        
        % first save settings
        save_settings();
        
        % only filter kymo's that have already been found.
        import Core.hpfl_extract;
        [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets,dbmStruct.fileCells);

%         import Core.hpfl_odm_extract;
%         [dbmStruct.fileCells, dbmStruct.fileMoleculeCells] = hpfl_odm_extract(dbmOSW.DBMSettingsstruct);
        show_home();
    end


    function show_home()

        
%         f= figure;
%         axes(hHomeScreen);
        numP = ceil(sqrt(length(dbmStruct.fileCells)));
        hHomeScreenTile = tiledlayout(hHomeScreen,ceil(length(dbmStruct.fileCells)/numP),numP,'TileSpacing','none','Padding','none');
%                   set(gca,'XTick',[])
%             set(gca,'YTick',[])
        for jj=1:length(dbmStruct.fileCells)
            hAxis = nexttile(hHomeScreenTile);
            hold on
            set(gca,'color',[0 0 0])
            set(hAxis,'XTick',[])
            set(hAxis,'YTick',[])

            %            imagesc(dbmStruct.fileCells{jj}.averagedImg)
            moleculeRectPositions = cell(1,length( dbmStruct.fileCells{jj}.locs));
            for ii=1:length(dbmStruct.fileCells{jj}.locs)
%                 moleculeRectPositions{ii} = [ dbmStruct.fileCells{jj}.locs(ii)-1 dbmStruct.fileCells{jj}.regions(ii,1)  3 dbmStruct.fileCells{jj}.regions(ii,2)- dbmStruct.fileCells{jj}.regions(ii,1)];
                moleculeRectPositions{ii} = [  dbmStruct.fileCells{jj}.regions(ii,1) dbmStruct.fileCells{jj}.locs(ii)-1  dbmStruct.fileCells{jj}.regions(ii,2)- dbmStruct.fileCells{jj}.regions(ii,1) 3];

            end
            import OldDBM.General.UI.disp_rect_annotated_image;
            [fb,fe] = fileparts(dbmStruct.fileCells{jj}.fileName);
            disp_rect_annotated_image(hAxis, dbmStruct.fileCells{jj}.averagedImg', fe, moleculeRectPositions);

        end
        tsHCC.SelectedTab = hHomeScreen;
%         select(hHomeScreen);
        
        
    end

    % saving session data
    function save_session_data(src,event)
        import OldDBM.General.Export.export_dbm_session_struct_mat;
        %             if nargin < 2
        defaultOutputDirpath = dbmOSW.get_default_export_dirpath('session');
        %             end
        dbmODW.DBMMainstruct = dbmStruct;
        dbmOSW.DBMSettingsstruct = sets;
        export_dbm_session_struct_mat(dbmODW, dbmOSW, defaultOutputDirpath);  
    end



    function [] = export_raw_kymos(src,event)
%         import OldDBM.General.Export.export_raw_kymos;
    %             if nargin < 2

    	if sets.choose_output_folder
            defaultOutputDirpath = dbmOSW.get_default_export_dirpath('raw_kymo');
            outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Raw Kymo Files');
        else
            outputDirpath = sets.outputDirpath;
        end
        
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
        dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
    
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(rawKymo, fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
        dbmStruct.kymoCells.rawBitmask, dbmStruct.kymoCells.rawBitmaskName);
    
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(rawKymo, fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
        dbmStruct.kymoCells.enhanced, dbmStruct.kymoCells.enhancedName);
    end
    
    function [] = export_aligned_kymos(src,event)
        import OldDBM.General.Export.export_aligned_kymos;

        defaultOutputDirpath = dbmOSW.get_default_export_dirpath('aligned_kymo');
        outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Aligned Kymo Files');

        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
        dbmStruct.kymoCells.alignedKymos, dbmStruct.kymoCells.alignedNames);
    
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
        dbmStruct.kymoCells.alignedBitmasks, dbmStruct.kymoCells.alignedNamesBitmask);
    
%         cellfun(@(rawKymo, outputKymoFilepath)...
%         imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
%         dbmStruct.kymoCells.rawBitmask, dbmStruct.kymoCells.rawBitmaskName);

    end
    
    function [] = export_time_averages_kymos(src,event)
        defaultOutputDirpath = dbmOSW.get_default_export_dirpath('aligned_kymo_time_avg');
        outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Barcode .mat files');

        cellfun(@(rawBarcode, outputKymoFilepath)...
        save( fullfile(outputDirpath,strrep(outputKymoFilepath,'.tif','.mat')), 'rawBarcode'),...
        dbmStruct.kymoCells.barcodes, dbmStruct.kymoCells.alignedNames);
    
        % todo: add bitmask to make this hca'esque, single file, so it can
        % be loaded in HCA.
%     
%     
%         for ix=1:
%         save(aligned_kymo_time_avg

        
    end


    % loading session data

    function load_session_data(src,event)
        
        defaultSessionDirpath = dbmOSW.get_default_import_dirpath('session');

        import OldDBM.General.Import.try_prompt_single_session_filepath;
        sessionFilepath = try_prompt_single_session_filepath(defaultSessionDirpath);

        if isempty(sessionFilepath)
            return;
        end

       
        dbmODW = load(sessionFilepath);
        
        sets = dbmODW.DBMSettingsstruct;
        dbmStruct = dbmODW.DBMMainstruct;

        show_home();
        
        
%                import Core.hpfl_extract;
%         [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets);


%         import OldDBM.General.Import.try_loading_from_session_file;
%         dbmODW2 = try_loading_from_session_file(sessionFilepath);
        
%                 dbmODW.DBMMainstruct = dbmStruct;
%         dbmOSW.DBMSettingsstruct = sets;

%         dbmODW.update_data(dbmODW2);
% 
%         import OldDBM.General.SettingsWrapper;
%         dbmOSW2 = SettingsWrapper.import_dbm_settings_from_session_path(sessionFilepath);
%         dbmOSW.update_settings(dbmOSW2);
% 
%         on_update_home_screen(dbmODW, tsDBM);

        
%         import OldDBM.General.Export.export_dbm_session_struct_mat;
%         %             if nargin < 2
%         defaultOutputDirpath = dbmOSW.get_default_export_dirpath('session');
%         %             end
%         dbmODW.DBMMainstruct = dbmStruct;
%         dbmOSW.DBMSettingsstruct = sets;
%         export_dbm_session_struct_mat(dbmODW, dbmOSW, defaultOutputDirpath);  
    end


    function load_kymo_data(src,event)
        
%         defaultSessionDirpath = dbmOSW.get_default_import_dirpath('session');
% 
        import OldDBM.General.Import.import_raw_kymos;
        [dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName,...
            dbmStruct.kymoCells.rawBitmask,dbmStruct.kymoCells.enhanced]  = import_raw_kymos();

        
        display_raw_kymographs()
%         if isempty(sessionFilepath)
%             return;
%         end
% 
%        
% %         dbmODW = load(sessionFilepath);
%         
%         sets = dbmODW.DBMSettingsstruct;
%         dbmStruct = dbmODW.DBMMainstruct;

        show_home();
        
        
%                import Core.hpfl_extract;
%         [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets);


%         import OldDBM.General.Import.try_loading_from_session_file;
%         dbmODW2 = try_loading_from_session_file(sessionFilepath);
        
%                 dbmODW.DBMMainstruct = dbmStruct;
%         dbmOSW.DBMSettingsstruct = sets;

%         dbmODW.update_data(dbmODW2);
% 
%         import OldDBM.General.SettingsWrapper;
%         dbmOSW2 = SettingsWrapper.import_dbm_settings_from_session_path(sessionFilepath);
%         dbmOSW.update_settings(dbmOSW2);
% 
%         on_update_home_screen(dbmODW, tsDBM);

        
%         import OldDBM.General.Export.export_dbm_session_struct_mat;
%         %             if nargin < 2
%         defaultOutputDirpath = dbmOSW.get_default_export_dirpath('session');
%         %             end
%         dbmODW.DBMMainstruct = dbmStruct;
%         dbmOSW.DBMSettingsstruct = sets;
%         export_dbm_session_struct_mat(dbmODW, dbmOSW, defaultOutputDirpath);  
    end


    function display_raw_kymographs(src, event)
    % 1: verify information score & length, etc. threshold
    
        numP = ceil(sqrt(length(dbmStruct.kymoCells.rawKymos)));
        hPanelRawKymosTile = tiledlayout(hPanelRawKymos,numP,numP,'TileSpacing','none','Padding','none');
%                   set(gca,'XTick',[])
%             set(gca,'YTick',[])
        for jj=1:length(dbmStruct.kymoCells.rawKymos)
            hAxis = nexttile(hPanelRawKymosTile);
            hold on
            set(gca,'color',[0 0 0]);
            set(hAxis,'XTick',[]);
            set(hAxis,'YTick',[]);
            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
            import OldDBM.General.UI.disp_img_with_header;
            disp_img_with_header(hAxis, dbmStruct.kymoCells.rawKymos{jj}, fe);
%             disp_rect_annotated_image(, fe, {});

        end
        tsHCC.SelectedTab = hPanelRawKymos;
    end

    function display_aligned_kymographs(src, event)
        numK = length(dbmStruct.kymoCells.rawKymos);
        numP = ceil(sqrt(numK));

        if ~isfield(dbmStruct.kymoCells,'alignedKymos')
            import OptMap.KymoAlignment.NRAlign.nralign;
%             import DBM4.kymograph_align;

            for ix=1:numK
                    fprintf('Aligning kymograph for file molecule #%d of #%d ...\n', ix, numK);
                    [alignedKymo, stretchFactorsMat, shiftAlignedKymo] = nralign(dbmStruct.kymoCells.rawKymos{ix},false,dbmStruct.kymoCells.rawBitmask{ix});

%                     [alignedKymo, stretchFactorsMat, shiftAlignedKymo] = kymograph_align(dbmStruct.kymoCells.rawKymos{ix},false,dbmStruct.kymoCells.rawBitmask{ix});
                    dbmStruct.kymoCells.alignedKymos{ix} = alignedKymo;
                    dbmStruct.kymoCells.alignedBitmasks{ix} = ~isnan(alignedKymo);
                    dbmStruct.kymoCells.stretchFactorsMat{ix} = stretchFactorsMat;
                    dbmStruct.kymoCells.shiftAlignedKymo{ix} = shiftAlignedKymo;     
                    dbmStruct.kymoCells.alignedNames{ix} =  strrep(dbmStruct.kymoCells.rawKymoName{ix},'_kymograph','_alignedkymograph');
                    dbmStruct.kymoCells.alignedNamesBitmask{ix} =  strrep(dbmStruct.kymoCells.rawBitmaskName{ix},'_bitmask','_alignedbitmask');

            end 
        end
        
        
        hPanelAlignedKymosTile = tiledlayout(hPanelAlignedKymos,numP,numP,'TileSpacing','none','Padding','none');
%                   set(gca,'XTick',[])
%             set(gca,'YTick',[])
        for jj=1:numK
            hAxis = nexttile(hPanelAlignedKymosTile);
            hold on
            set(gca,'color',[0 0 0]);
            set(hAxis,'XTick',[]);
            set(hAxis,'YTick',[]);
            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
            import OldDBM.General.UI.disp_img_with_header;
            disp_img_with_header(hAxis, dbmStruct.kymoCells.alignedKymos{jj}, fe);
%             disp_rect_annotated_image(, fe, {});

        end
        tsHCC.SelectedTab = hPanelAlignedKymos; 
    end

    function display_time_averages(src,event)
        numK = length(dbmStruct.kymoCells.rawKymos);
        numP = ceil(sqrt(numK));
        
        if  ~isfield(dbmStruct.kymoCells,'alignedKymos')
            display_aligned_kymographs;
        end


        if  ~isfield(dbmStruct.kymoCells,'barcodes')
            for ix=1:numK
                dbmStruct.kymoCells.barcodes{ix} = nanmean(dbmStruct.kymoCells.alignedKymos{ix},1);
                dbmStruct.kymoCells.barcodesStd{ix} = nanstd(dbmStruct.kymoCells.alignedKymos{ix},1,1);
                dbmStruct.kymoCells.numsKymoFrames(ix) = size(dbmStruct.kymoCells.alignedKymos{ix},1);
                bitmask = ~isnan(dbmStruct.kymoCells.alignedKymos{ix});
                dbmStruct.kymoCells.fgStartIdxs{ix} = arrayfun(@(x) find(bitmask(x,:),1,'first'),1:size(bitmask,1));
                dbmStruct.kymoCells.fgEndIdxs{ix} = arrayfun(@(x) find(bitmask(x,:),1,'last'),1:size(bitmask,1));
                dbmStruct.kymoCells.fgStartIdxsMean(ix) = round(mean( dbmStruct.kymoCells.fgStartIdxs{ix}));
                dbmStruct.kymoCells.fgEndIdxsMean(ix) = round(mean(  dbmStruct.kymoCells.fgEndIdxs{ix}));
            end
        end
        
%            import OldDBM.Kymo.UI.plot_aligned_kymo_time_avgs;
%     plot_aligned_kymo_time_avgs(hFgKymoTimeAvgAxes, headerTexts, fgStartIdxs, fgEndIdxs,   dbmStruct.kymoCells.barcodes,  dbmStruct.kymoCells.barcodesStd, numsKymoFrames);
    
        hPanelTimeAveragesTile = tiledlayout(hPanelTimeAverages,numP,numP,'TileSpacing','none','Padding','none');
        import OldDBM.Kymo.UI.plot_aligned_kymo_time_avg;

%                   set(gca,'XTick',[])
%             set(gca,'YTick',[])
        for jj=1:numK
            hAxis = nexttile(hPanelTimeAveragesTile);
            hold on
            set(gca,'color',[0 0 0]);
%             set(hAxis,'XTick',[]);
%             set(hAxis,'YTick',[]);
            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
%             import OldDBM.General.UI.disp_img_with_header;
            plot_aligned_kymo_time_avg(hAxis, fe,  dbmStruct.kymoCells.fgStartIdxsMean(jj), dbmStruct.kymoCells.fgEndIdxsMean(jj),...
                dbmStruct.kymoCells.barcodes{jj} , dbmStruct.kymoCells.barcodesStd{jj}, dbmStruct.kymoCells.numsKymoFrames(jj));

%             disp_img_with_header(hAxis, dbmStruct.kymoCells.alignedKymos{jj}, fe);
%             disp_rect_annotated_image(, fe, {});

        end
        tsHCC.SelectedTab = hPanelTimeAverages; 
 
    end

%     function display_time_averages(src,event)
%         % we find and display lambda's among the detected barcodes
%         
%         
%         
%     end


    % Import tiff
    function SelectedImportTif(src, event)
        disp('Select file to open')
       [rawMovieFilenames, rawMovieDirpath] = uigetfile(...
            {'*.tif;*.tiff;*.czi'}, ...
            strcat(['Select raw file(s) to import']), ...
            pwd, ...
            'MultiSelect','on');
            
        if ~iscell(rawMovieFilenames)
            dbmStruct.rawMovieFilenames = {rawMovieFilenames};
        else
            dbmStruct.rawMovieFilenames = rawMovieFilenames;
        end
        dbmStruct.rawMovieDirPath = rawMovieDirpath;

        disp(strcat(['Selected ' num2str(length( dbmStruct.rawMovieFilenames )) ' movies']));  
        
%         dbmOSW.DBMSettingsstruct.movies.movieFile = 'testmov.txt';
        sets.movies.movieNames = cellfun(@(x) fullfile(dbmStruct.rawMovieDirPath ,x), dbmStruct.rawMovieFilenames,'un',false);

%         
%         % save filenames to a txt file
%         fd =fopen(dbmOSW.DBMSettingsstruct.movies.movieFile);
%         filePh = fopen(dbmOSW.DBMSettingsstruct.movies.movieFile,'w');
%         fprintf(filePh,'%s\n', filesC{:});
%         fclose(filePh);


        % Now run main algorithm: High-Precision-Fluorophore-Localization
        import Core.hpfl_extract;
        [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets);

%         import Core.hpfl_odm_extract;
%         [dbmStruct.fileCells, dbmStruct.fileMoleculeCells] = hpfl_odm_extract(dbmOSW.DBMSettingsstruct);
        show_home();

    end



        function SelectedConvertToTif(src, event)
            disp('Select files to convert to tif')
            import DBM4.convert_czi_to_tif;
            convert_czi_to_tif;
%         
%        [rawMovieFilenames, rawMovieDirpath] = uigetfile(...
%             {'*.tif;*.tiff;*.mat;*.fasta;*.fa'}, ...
%             strcat(['Select raw file(s) to import']), ...
%             pwd, ...
%             'MultiSelect','on');
%             
%         if ~iscell(rawMovieFilenames)
%             dbmStruct.rawMovieFilenames = {rawMovieFilenames};
%             dbmStruct.rawMovieDirPath = {rawMovieDirpath};
% 
%         else
%             dbmStruct.rawMovieFilenames = [];
%             dbmStruct.rawMovieDirPath = [];
% 
%         end
%         disp(strcat(['Selected ' num2str(length( dbmStruct.rawMovieFilenames )) ' movies']));  
    end
    
        function [sets,tsHCC,textList,textListT,itemsList,...
               hHomeScreen, hPanelRawKymos,hPanelAlignedKymos,hPanelTimeAverages,hAdditional] = generate_gui()
      
            hFig = figure('Name', 'DNA Barcode Matchmaker v0.6.6', ...% get from VERSION file
                'Units', 'normalized', ...
                'OuterPosition', [0.05 0.1 0.8 0.8], ...
                'NumberTitle', 'off',... 
                'MenuBar', 'none',...
                'ToolBar', 'none' ...
            );
            m = uimenu('Text','DBM');
            cells1 = {'Import','Export','Kymographs','Statistics','Convert czi to tif','Pipelines'};
            mSub = cellfun(@(x) uimenu(m,'Text',x),cells1,'un',false);
            mSub{5}.MenuSelectedFcn = @SelectedConvertToTif;


            cellsImport = {'Load Session Data','Convert czi to tif','Load Movie(s) (tif format)','Load Raw Kymograph(s)'};

            cellsExport = {'Save Session Data','Raw kymographs','Aligned Kymographs','Time Averages'};
            cellsKymographs = {'Display Raw kymographs','Display Aligned Kymographs','Plot Time Averages','Display lambdas','Filter molecules'};
            cellsStatistics = {'Calculate molecule lengths and intensities','Calculate Raw Kymos Center of Mass'};
            cellsPipelines = {'Genome assembly','Lambda lengths'};

            mSubImport = cellfun(@(x) uimenu(mSub{1},'Text',x),cellsImport,'un',false);
            mSubExport = cellfun(@(x) uimenu(mSub{2},'Text',x),cellsExport,'un',false);
            mSubKymographs = cellfun(@(x) uimenu(mSub{3},'Text',x),cellsKymographs,'un',false);
            mSubStatistics = cellfun(@(x) uimenu(mSub{4},'Text',x),cellsStatistics,'un',false);

            mSubImport{1}.MenuSelectedFcn = @load_session_data;
            mSubImport{2}.MenuSelectedFcn = @SelectedConvertToTif;
            mSubImport{3}.Accelerator = 'L';
            mSubImport{3}.MenuSelectedFcn = @SelectedImportTif;
            mSubImport{4}.MenuSelectedFcn = @load_kymo_data;

            mSubExport{1}.MenuSelectedFcn = @save_session_data;
            mSubExport{2}.MenuSelectedFcn = @export_raw_kymos;
            mSubExport{3}.MenuSelectedFcn = @export_aligned_kymos;
            mSubExport{4}.MenuSelectedFcn = @export_time_averages_kymos;


            mSubKymographs{1}.MenuSelectedFcn = @display_raw_kymographs;
            mSubKymographs{2}.MenuSelectedFcn = @display_aligned_kymographs;
            mSubKymographs{3}.MenuSelectedFcn = @display_time_averages;
            mSubKymographs{4}.MenuSelectedFcn = @display_lambdas;
            mSubKymographs{5}.MenuSelectedFcn = @filter_molecules;

            mSubStatistics{1}.MenuSelectedFcn = @calculate_lengths;
            mSubStatistics{2}.MenuSelectedFcn = @calculate_com;

            mSubPipelines = cellfun(@(x) uimenu(mSub{6},'Text',x),cellsPipelines,'un',false);
            mSubPipelines{1}.MenuSelectedFcn = @genome_assembly_pipeline;
            set( mSubPipelines{1}, 'Enable', 'off');
            set( mSubPipelines{2}, 'Enable', 'off');

            
%             mSubPipelines = cellfun(@(x) uimenu(mSub{4},'Text',x),cellsStatistics,'un',false);

            %
            hPanel = uipanel('Parent', hFig);
            h = uitabgroup('Parent',hPanel);
            t1 = uitab(h, 'title', 'DBM');
            tsHCC = uitabgroup('Parent',t1);
            hPanelImport = uitab(tsHCC, 'title', 'DBM settings');

            hHomeScreen= uitab(tsHCC, 'title',strcat('HomeScreen'));
            hPanelRawKymos= uitab(tsHCC, 'title',strcat('unaligned Kymos'));
            hPanelAlignedKymos = uitab(tsHCC, 'title',strcat('aligned Kymos'));
            hPanelTimeAverages = uitab(tsHCC, 'title',strcat('time Averages'));
            hAdditional.hAdd= uitab(tsHCC, 'title',strcat('Additional'));
            tshAdd = uitabgroup('Parent',hAdditional.hAdd);
            hAdditional.length = uitab(tshAdd, 'title',strcat('Mol lengths'));
        % set(hHomeScreen,'Visible','off')
            sets =  dbmOSW.DBMSettingsstruct;

                % Put the loaded settings into the GUI.
                    % make into loop
            checkItems =  {'Molecule angle calculation (skip if angle is known)','Single frame molecule detection','Denoise (Experimental)','Detect lambdas'};
            checkValues = [sets.moleculeAngleValidation  sets.timeframes  sets.denoise, sets.detectlambdas ] ;
           % checkbox for things to plot and threshold
            for i=1:length(checkItems)
                itemsList{i} = uicontrol('Parent', hPanelImport, 'Style', 'checkbox','Value',checkValues(i),'String',{checkItems{i}},'Units', 'normal', 'Position', [0.45 .83-0.05*i 0.3 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            end
            set(itemsList{2}, 'Enable', 'off');

            % parameters with initial values
           textItems =  {'averagingWindowWidth (px)','nmPerPixel (nm/px)','rowSidePadding (unused)','parForNoise','distbetweenChannels','numFrames',...
               'Max number frames (0-all)','timeframes (unused)','stdDifPos','numPts','minLen'};
           values =  {num2str(sets.averagingWindowWidth),num2str(sets.nmPerPixel),num2str(sets.rowSidePadding),num2str(sets.parForNoise),...
               num2str(sets.distbetweenChannels),num2str(sets.numFrames),...
               num2str(sets.max_number_of_frames),num2str(sets.timeframes),num2str(sets.stdDifPos), num2str(sets.numPts),num2str(sets.minLen)};

            for i=1:length(textItems) % these will be in two columns
                positionsText{i} =   [0.2-0.2*mod(i,2) .88-0.1*ceil(i/2) 0.2 0.03];
                positionsBox{i} =   [0.2-0.2*mod(i,2) .83-0.1*ceil(i/2) 0.15 0.05];
            end

        %     
        %     for i=7:11 % these will be in two columns
        %         positionsText{i} =   [0.2*(i-7) .45 0.15 0.03];
        %         positionsBox{i} =   [0.2*(i-7) .4 0.15 0.05];
        %     end

            for i=1:length(textItems)
                textListT{i} = uicontrol('Parent', hPanelImport, 'Style', 'text','String',{textItems{i}},'Units', 'normal', 'Position', positionsText{i},'HorizontalAlignment','Left');%, 'Max', Inf, 'Min', 0);  [left bottom width height]
                textList{i} = uicontrol('Parent', hPanelImport, 'Style', 'edit','String',{values{i}},'Units', 'normal', 'Position', positionsBox{i});%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            end
            set(textList{8}, 'Enable', 'off');
            set(textList{6}, 'Enable', 'off');


            runButton = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Save settings'},'Callback',@save_settings,'Units', 'normal', 'Position', [0.7 0.4 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            clearButton = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Restore settings'},'Callback',@restore_settings,'Units', 'normal', 'Position', [0.7 0.3 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            reRunButton = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Re-run analysis'},'Callback',@re_run,'Units', 'normal', 'Position', [0.7 0.2 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            reRunFiltering = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Re-run filtering kymos'},'Callback',@re_run_filtering,'Units', 'normal', 'Position', [0.7 0.1 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]

        end
    
    function calculate_lengths(src, event)
        import OldDBM.Kymo.UI.prompt_kymo_analysis_method;
        [kymoAnalysisMethod, shouldSaveTF] = prompt_kymo_analysis_method();
        
        skipEdgeDetection = false;
        skipDoubleTanhAdjustmentTF = true;
        switch kymoAnalysisMethod
            case 'kymo_edge'
                skipEdgeDetection = true;
%             case 'basic_otsu_edge_detection'
%                 skipDoubleTanhAdjustmentTF = true;
%             case 'double_tanh_edge_detection'
%                 skipDoubleTanhAdjustmentTF = false;
            otherwise
                return;
        end
        %         import OldDBM.Kymo.UI.run_calc_plot_save_kymo_analysis;
%         import DBM4.run_calc_plot_save_kymo_analysis;
        run_calculate_lengths(skipDoubleTanhAdjustmentTF, shouldSaveTF,sets,skipEdgeDetection);
        
        % plot
        numP = ceil(sqrt(length(dbmStruct.kymoCells.rawKymos)));
        hPanelRawKymosTile = tiledlayout(hAdditional.length,numP,numP,'TileSpacing','none','Padding','none');
%                   set(gca,'XTick',[])
%             set(gca,'YTick',[])
        for jj=1:length(dbmStruct.kymoCells.rawKymos)
            hAxis = nexttile(hPanelRawKymosTile);
            hold on
            set(gca,'color',[0 0 0]);
            set(hAxis,'XTick',[]);
            set(hAxis,'YTick',[]);
            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});

            % Show the raw kymographs with labeled edges and header text on
            %  their alloted axis handles
       
    
            import OldDBM.General.UI.disp_img_with_header;
            disp_img_with_header(hAxis, dbmStruct.kymoCells.rawKymos{jj}, fe);
            import DBM4.plot_kymo_edges;

                 plot_kymo_edges(hAxis,...
            dbmStruct.kymoCells.kymosMoleculeLeftEdgeIdxs{jj}', ...
            dbmStruct.kymoCells.kymosMoleculeRightEdgeIdxs{jj}');
    
        
%             disp_rect_annotated_image(, fe, {});

        end
        tsHCC.SelectedTab = hAdditional.hAdd;

     
    end

function [] = run_calculate_lengths(skipDoubleTanhAdjustmentTF, shouldSaveTF, sets, skipEdgeDetection)
    %
    %   Args:
    %       tsDBM, dbmODW, skipDoubleTanhAdjustmentTF, shouldSavePngTF
    %
    %   Returns:
    %
    % TODO:
    
% %     % generate
    import DBM4.run_kymo_analysis;
    kymoStatsTable = run_kymo_analysis(dbmStruct.kymoCells,skipEdgeDetection);
% % 
    defaultStatsOutputDirpath =   sets.dirs.stats;
% %     
% %     % add timestamp
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    filename = sprintf('stats_%s.mat', timestamp);
% % 
    defaultStatsOutputFilepath = fullfile(defaultStatsOutputDirpath, filename);
    [statsOutputMatFilename, statsOutputMatDirpath, ~] = uiputfile('*.mat', 'Save Molecule Stats As', defaultStatsOutputFilepath);
% %     
    if not(isequal(statsOutputMatDirpath, 0))
       statsOutputMatFilepath = fullfile(statsOutputMatDirpath, statsOutputMatFilename);
       save(statsOutputMatFilepath, 'kymoStatsTable');

        numRows = size(kymoStatsTable, 1);
        for rowIdx = 1:numRows
            fileIdx = kymoStatsTable(rowIdx, :).fileIdx;
            fileMoleculeIdx = kymoStatsTable(rowIdx, :).fileMoleculeIdx;
            srcFilename = kymoStatsTable{rowIdx, 'srcFilename'};
            if iscell(srcFilename)
                if isempty(srcFilename)
                    srcFilename = '';
                else
                    srcFilename = srcFilename{1};
                end
            end
            [~, name] = fileparts(srcFilename);
            csvFilename = sprintf('stats_%d_(%s)_%d.csv', fileIdx, name, fileMoleculeIdx);
            csvFilepath = fullfile(statsOutputMatDirpath, csvFilename);

            framewiseStatsTable = struct();
            framewiseStatsTable.moleculeLeftEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeLeftEdgeIdxs'}{1};
            framewiseStatsTable.moleculeRightEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeRightEdgeIdxs'}{1};
            framewiseStatsTable.framewiseMoleculeExts = kymoStatsTable{rowIdx, 'framewiseMoleculeExts'}{1};
            framewiseStatsTable.meanFramewiseMoleculeIntensity = kymoStatsTable{rowIdx, 'meanFramewiseMoleculeIntensity'}{1};
            framewiseStatsTable.stdFramewiseMoleculeIntensity = kymoStatsTable{rowIdx, 'stdFramewiseMoleculeIntensity'}{1};
            framewiseStatsTable = struct2table(framewiseStatsTable);
            writetable(framewiseStatsTable, csvFilepath);
        end
    end
% % 
% %     [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();
% % 
% %     [moleculeStatuses] = dbmODW.get_molecule_statuses(fileIdxs, fileMoleculeIdxs);
% %     selectionMask = moleculeStatuses.hasRawKymo;
% %     % selectionMask = selectionMask & moleculeStatuses.passesFilters;
% % 
% %     fileIdxs = fileIdxs(selectionMask);
% %     fileMoleculeIdxs = fileMoleculeIdxs(selectionMask);
% % 
% %     numKymos = length(fileMoleculeIdxs);
% %     kymosMoleculeLeftEdgeIdxs = cell(numKymos, 1);
% %     kymosMoleculeRightEdgeIdxs = cell(numKymos, 1);
% %     for kymoNum = 1:numKymos
% %         fileIdx = fileIdxs(kymoNum);
% %         fileMoleculeIdx = fileMoleculeIdxs(kymoNum);
% %         rowIdx = find((kymoStatsTable.fileIdx == fileIdx) & (kymoStatsTable.fileMoleculeIdx == fileMoleculeIdx), 1, 'first');
% %         
% %         if not(isempty(rowIdx))
% %             kymoMoleculeLeftEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeLeftEdgeIdxs'}{1};
% %             kymoMoleculeRightEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeRightEdgeIdxs'}{1};
% %             kymosMoleculeLeftEdgeIdxs{kymoNum} = kymoMoleculeLeftEdgeIdxs;
% %             kymosMoleculeRightEdgeIdxs{kymoNum} = kymoMoleculeRightEdgeIdxs;
% %         end
% %     end
% % 
% %     % [kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs] = dbmODW.get_raw_kymos_molecules_edge_idxs(fileIdxs, fileMoleculeIdxs);
% %     
% %     % should not display this if there are too many molecules..!
% %     
% %     if shouldSavePngTF ~= 2
% %         hTabEdgeDetection = tsDBM.create_tab('Raw Kymo Edge Detection');
% %         tsDBM.select_tab(hTabEdgeDetection);
% %         hPanel = uipanel('Parent', hTabEdgeDetection);
% %     % hPanel = figure('visible','off');
% %         import OldDBM.Kymo.UI.plot_detected_raw_kymo_edges;
% %         hAxesPlots = plot_detected_raw_kymo_edges(dbmODW, fileIdxs, fileMoleculeIdxs, hPanel, kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs);
% %     end
% %     
% %     if not(shouldSavePngTF)
% %         return;
% %     end
% %     
% %     
% %     import OldDBM.Kymo.Helper.get_raw_kymo_edge_plot_png_output_filepaths;
% %     pngOutputFilepaths = get_raw_kymo_edge_plot_png_output_filepaths(dbmODW, fileIdxs, fileMoleculeIdxs, settings.dirs.pngs,timestamp);
% % 
% %     fprintf('Saving kymographs with edges as png files...\n');
% %     if shouldSavePngTF ~= 2
% %     % Save images of the axes
% %         import OldDBM.General.Export.export_axis_image_as_png;
% %         arrayfun(@(kymoIdx) export_axis_image_as_png(hAxesPlots(kymoIdx), pngOutputFilepaths{kymoIdx}), (1:numKymos)', 'UniformOutput', false);
% %     else
% %         import DBM4.export_image_as_png;
% %         export_image_as_png(dbmODW, fileIdxs, fileMoleculeIdxs,kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs,pngOutputFilepaths);
% %     end
% %     fprintf('Finished saving png files.\n');

end



function genome_assembly_pipeline(src, event)
    % from czi/tifs to kymos/barcodes
%     save_settings(); % first save settigns

    import Core.hpfl_extract;
    [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets);
    export_raw_kymos();
    
    import OptMap.KymoAlignment.NRAlign.nralign;
    %             import DBM4.kymograph_align;
    numK = length(dbmStruct.kymoCells.rawKymos);
    numP = ceil(sqrt(numK));
    for ix=1:numK
            fprintf('Aligning kymograph for file molecule #%d of #%d ...\n', ix, numK);
            [alignedKymo, stretchFactorsMat, shiftAlignedKymo] = nralign(dbmStruct.kymoCells.rawKymos{ix},false,dbmStruct.kymoCells.rawBitmask{ix});

%                     [alignedKymo, stretchFactorsMat, shiftAlignedKymo] = kymograph_align(dbmStruct.kymoCells.rawKymos{ix},false,dbmStruct.kymoCells.rawBitmask{ix});
            dbmStruct.kymoCells.alignedKymos{ix} = alignedKymo;
            dbmStruct.kymoCells.alignedBitmasks{ix} = ~isnan(alignedKymo);
            dbmStruct.kymoCells.stretchFactorsMat{ix} = stretchFactorsMat;
            dbmStruct.kymoCells.shiftAlignedKymo{ix} = shiftAlignedKymo;     
            dbmStruct.kymoCells.alignedNames{ix} =  strrep(dbmStruct.kymoCells.rawKymoName{ix},'_kymograph','_alignedkymograph');
            dbmStruct.kymoCells.alignedNamesBitmask{ix} =  strrep(dbmStruct.kymoCells.rawBitmaskName{ix},'_bitmask','_alignedbitmask');

    end 
    for ix=1:numK
        dbmStruct.kymoCells.barcodes{ix} = nanmean(dbmStruct.kymoCells.alignedKymos{ix},1);
        dbmStruct.kymoCells.barcodesStd{ix} = nanstd(dbmStruct.kymoCells.alignedKymos{ix},1,1);
        dbmStruct.kymoCells.numsKymoFrames(ix) = size(dbmStruct.kymoCells.alignedKymos{ix},1);
        bitmask = ~isnan(dbmStruct.kymoCells.alignedKymos{ix});
        dbmStruct.kymoCells.fgStartIdxs{ix} = arrayfun(@(x) find(bitmask(x,:),1,'first'),1:size(bitmask,1));
        dbmStruct.kymoCells.fgEndIdxs{ix} = arrayfun(@(x) find(bitmask(x,:),1,'last'),1:size(bitmask,1));
        dbmStruct.kymoCells.fgStartIdxsMean(ix) = round(mean( dbmStruct.kymoCells.fgStartIdxs{ix}));
        dbmStruct.kymoCells.fgEndIdxsMean(ix) = round(mean(  dbmStruct.kymoCells.fgEndIdxs{ix}));
    end
    save_session_data();
%     assignin('base','fileStructOut',fileStruct);
    assignin('base','dbmStruct',dbmStruct);
%     save('kymoCellsOut.mat','kymoCellsOut')

end

end


function [] = calculate_com(src, event)
    if nargin < 3
        writeToTSV = true;
    end
    % todo..

%     import OldDBM.Kymo.Core.calc_raw_kymos_centers_of_mass;
%     [centerOfMassTable] = calc_raw_kymos_centers_of_mass(dbmODW);
%     disp(centerOfMassTable);
% 
%     if writeToTSV
%         timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
%         defaultOutputDirpath = dbmOSW.get_default_export_dirpath('raw_kymo_center_of_mass');
%         defaultOutputFilename = sprintf('centerOfMassTable_%s.tsv', timestamp);
%         defaultOutputFilepath = fullfile(defaultOutputDirpath, defaultOutputFilename);
% 
%         [outputFilename, outputDirpath] = uiputfile('*.tsv', 'Save Centers of Mass As', defaultOutputFilepath);
% 
%         if isequal(outputDirpath, 0)
%             return;
%         end
%         outputFilepath = fullfile(outputDirpath, outputFilename);
% 
%         writetable(centerOfMassTable, outputFilepath, ...
%             'Delimiter', sprintf('\t'), ...
%             'FileType', 'text');
%     end


end
