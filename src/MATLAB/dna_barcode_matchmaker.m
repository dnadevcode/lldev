function [] = dna_barcode_matchmaker(useGUI, dbmOSW)
    % Replicates DBM_GUI but with simplified structures
    
    %   Args:
    %       useGUI - whether to run user friendly GUI
    %       dbmOSW - nput settings

    % Main functions called by this
    % Core.hpfl_extract
    %

    import OldDBM.General.SettingsWrapper;
    import Core.hpfl_extract;
        
    if nargin < 2
        % Get default settings path
        import DBM4.UI.find_default_settings_path;
        defaultSettingsFilepath = find_default_settings_path('DBMnew.ini');
        import Fancy.IO.ini2struct;
        dbmOSW.DBMSettingsstruct = ini2struct(defaultSettingsFilepath);

        dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm'; 
    end
    
    if nargin >=1
        dbmOSW.DBMSettingsstruct.useGUI = useGUI;  
    end

    if dbmOSW.DBMSettingsstruct.useGUI
        % generate menu
        % https://se.mathworks.com/help/matlab/ref/uimenu.html
        [sets,tsHCC,textList,textListT,itemsList,...
                hHomeScreen,hPanelRawKymos,hPanelAlignedKymos,hPanelTimeAverages,hAdditional,tshAdd]= generate_gui();
    else
        if dbmOSW.DBMSettingsstruct.auto_run     
            [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(dbmOSW.DBMSettingsstruct);

            [sets,tsHCC,textList,textListT,itemsList,...
            hHomeScreen,hPanelRawKymos,hPanelAlignedKymos,hPanelTimeAverages,hAdditional,tshAdd]= generate_gui();
        
            show_home();
        else
            sets = dbmOSW.DBMSettingsstruct;
        end
    end
    
    if dbmOSW.DBMSettingsstruct.genome_assembly_pipeline
        genome_assembly_pipeline()        
    end

    function save_settings(src, event) % all changeable settings here
        % save settings from menu.    
        sets.averagingWindowWidth = str2double(textList{1}.String);
        sets.nmPerPixel =  str2double(textList{2}.String);
    
        sets.distbetweenChannels = str2double(textList{3}.String);
        
        sets.max_number_of_frames =  str2double(textList{4}.String);

        sets.stdDifPos  = str2double(textList{5}.String);
        sets.numPts  = str2double(textList{6}.String);
        sets.minLen  = str2double(textList{7}.String);
        sets.SigmaLambdaDet  = str2double(textList{8}.String);
        
        sets.initialAngle  = str2double(textList{9}.String);
        sets.minAngle  = str2double(textList{10}.String);


        sets.moleculeAngleValidation = itemsList{1}.Value;
        sets.timeframes = itemsList{2}.Value;
        sets.denoise = itemsList{3}.Value;
        sets.detectlambdas  = itemsList{4}.Value;
        sets.keepBadEdgeMols  = itemsList{5}.Value;

    end

    function restore_settings(src, event,x) % restore settings
        if nargin<3
            sets =  dbmOSW.DBMSettingsstruct;
        else
            sets = x;
        end
        % also uppdate values
        textList{1}.String = num2str(sets.averagingWindowWidth );
        textList{2}.String   =  num2str(sets.nmPerPixel);

        textList{3}.String   = num2str(sets.distbetweenChannels);

        textList{4}.String  =  num2str(sets.max_number_of_frames);

        textList{5}.String  =  num2str(sets.stdDifPos);
        textList{6}.String  =  num2str(sets.numPts);
        textList{7}.String  =  num2str(sets.minLen);
        textList{8}.String  =  num2str(sets.SigmaLambdaDet);
        textList{9}.String  =  num2str(sets.initialAngle);
        textList{10}.String  =  num2str(sets.minAngle);


        itemsList{1}.Value =  sets.moleculeAngleValidation;
        itemsList{2}.Value = sets.timeframes;
        itemsList{3}.Value  =  sets.denoise;
        itemsList{4}.Value  =  sets.detectlambdas;
        itemsList{5}.Value  =  sets.keepBadEdgeMols;

    end

    function re_run(src, event)        
        save_settings(); % first save settigns
        
        import Core.hpfl_extract;
        [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets);

        show_home();
    end


    function re_run_filtering(src, event)
        
        % first save settings
        save_settings();      
        % only filter kymo's that have already been found.
        import Core.hpfl_extract;
        [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets,dbmStruct.fileCells);
        show_home();
    end


    function show_home()
        % Shows home screen:
        % future: from update 0.10.0.0: no longer display all movies by default, but give an
        % option for the user of what they want to see. Maybe as a slider?
        % shows home tile
        numP = max(1,ceil(sqrt(length(dbmStruct.fileCells))));
        numRows = max(1,ceil(length(dbmStruct.fileCells)/numP));

        hHomeScreenTile = tiledlayout(hHomeScreen,numRows,numP,'TileSpacing','tight','Padding','tight');
        % for each tile, plot rectangle with molecules
        sets.plotImages = 1;

        for jj=1:length(dbmStruct.fileCells)
            hAxis = nexttile(hHomeScreenTile);
            if  sets.plotImages
                % calc this directly before
                if isfield(dbmStruct.fileCells{jj},'meanStd')
                    imagesc(dbmStruct.fileCells{jj}.averagedImg', 'Parent', hAxis,[dbmStruct.fileCells{jj}.meanStd(1)-dbmStruct.fileCells{jj}.meanStd(2) dbmStruct.fileCells{jj}.meanStd(1)+5*dbmStruct.fileCells{jj}.meanStd(2)]);
                else
                    imagesc(dbmStruct.fileCells{jj}.averagedImg', 'Parent', hAxis);
                end
                hold(hAxis, 'on');
                set(hAxis,'XTick',[])
                set(hAxis,'YTick',[])
                colormap(hAxis, gray());
                
                % also plot barcodes that were removed for some reason
                
                % locations
                moleculeRectPositions = cell(1,length( dbmStruct.fileCells{jj}.locs));
                for ii=1:length(dbmStruct.fileCells{jj}.locs)
                    moleculeRectPositions{ii} = [  dbmStruct.fileCells{jj}.regions(ii,1) dbmStruct.fileCells{jj}.locs(ii)-floor(sets.averagingWindowWidth/2)-0.5  dbmStruct.fileCells{jj}.regions(ii,2)- dbmStruct.fileCells{jj}.regions(ii,1) sets.averagingWindowWidth];
                end
                
                try
                    cellfun(@(moleculeRectPosition) ...
                    rectangle(...
                        'Position', moleculeRectPosition, ...
                        'LineWidth', 0.2, ...
                        'EdgeColor', 'r'), ...
                    moleculeRectPositions);
                    % todo: this should be index in the final kymograph set
                    arrayfun(@(x) ...
                    text(moleculeRectPositions{x}(1), moleculeRectPositions{x}(2),strcat(['ID = ' num2str(x) ' , SNR =  ' num2str(dbmStruct.fileMoleculeCells{jj}{x}.snrValues(1),'%4.1f')] ),...
                    'Color','white','FontSize',8,'Clipping','on','HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom'), ...
                    1:length(moleculeRectPositions));
                catch
            
                end

            else
                tb = axtoolbar(hAxis , 'default');
                btn = axtoolbarbtn(tb,'Icon',1+63*(eye(25)),'Tooltip','Detailed molecule plot');
                btn.ButtonPushedFcn = @callbackDetailedPlot;
            end
            [fb,fe] = fileparts(dbmStruct.fileCells{jj}.fileName);
            title(strrep(fe,'_','\_'),'Interpreter','latex','FontSize',8)           
        end
%             axtoolbar(hHomeScreenTile,{'zoomin','zoomout','restoreview'});
%             ax = gca;
%             ax.Toolbar.Visible = 'on';
            tsHCC.SelectedTab = hHomeScreen; 
    end

    function callbackDetailedPlot(src,event)
    % calc this directly before
        if isfield(dbmStruct.fileCells{jj},'meanStd')
            imagesc(dbmStruct.fileCells{jj}.averagedImg', 'Parent', hAxis,[dbmStruct.fileCells{jj}.meanStd(1)-dbmStruct.fileCells{jj}.meanStd(2) dbmStruct.fileCells{jj}.meanStd(1)+5*dbmStruct.fileCells{jj}.meanStd(2)]);
        else
            imagesc(dbmStruct.fileCells{jj}.averagedImg', 'Parent', hAxis);
        end
        hold(hAxis, 'on');
        set(hAxis,'XTick',[])
        set(hAxis,'YTick',[])
        colormap(hAxis, gray());
        
        % also plot barcodes that were removed for some reason
        
        % locations
        moleculeRectPositions = cell(1,length( dbmStruct.fileCells{jj}.locs));
        for ii=1:length(dbmStruct.fileCells{jj}.locs)
            moleculeRectPositions{ii} = [  dbmStruct.fileCells{jj}.regions(ii,1) dbmStruct.fileCells{jj}.locs(ii)-floor(sets.averagingWindowWidth/2)-0.5  dbmStruct.fileCells{jj}.regions(ii,2)- dbmStruct.fileCells{jj}.regions(ii,1) sets.averagingWindowWidth];
        end
        
        try
            cellfun(@(moleculeRectPosition) ...
            rectangle(...
                'Position', moleculeRectPosition, ...
                'LineWidth', 0.2, ...
                'EdgeColor', 'r'), ...
            moleculeRectPositions);
            % todo: this should be index in the final kymograph set
            arrayfun(@(x) ...
            text(moleculeRectPositions{x}(1), moleculeRectPositions{x}(2),strcat(['ID = ' num2str(x) ' , SNR =  ' num2str(dbmStruct.fileMoleculeCells{jj}{x}.snrValues(1),'%4.1f')] ),...
            'Color','white','FontSize',8,'Clipping','on','HorizontalAlignment', 'left', 'VerticalAlignment', 'bottom'), ...
            1:length(moleculeRectPositions));
        catch
    
        end

    end

    % saving session data
    function save_session_data(src,event)
%         import OldDBM.General.Export.export_dbm_session_struct_mat;
        dbmODW.DBMMainstruct = dbmStruct;
        dbmOSW.DBMSettingsstruct = sets;

        import DBM4.Export.export_dbm_session_struct_mat;

        try 
            [defaultOutputDirpath,~] = fileparts(dbmOSW.DBMSettingsstruct.movies.movieNames{1});
            defaultOutputDirpath = fullfile(defaultOutputDirpath,'session');
        catch
            defaultOutputDirpath = DBM4.UI.default_output_path('Sessions');
%             defaultOutputDirpath = dbmOSW.get_default_export_dirpath('session');
        end
        %             if nargin < 2
        %             end

        
        export_dbm_session_struct_mat(dbmODW, dbmOSW, defaultOutputDirpath);  
        
        disp(['Session data saved at ',defaultOutputDirpath ])

    end

    % saving light session data (only kymo output. no calculations possible
    function save_light_session_data(src,event)
        import DBM4.Export.export_dbm_session_struct_mat;
        dbmOSW.DBMSettingsstruct = sets;

        try 
            [defaultOutputDirpath,~] = fileparts(dbmOSW.DBMSettingsstruct.movies.movieNames{1});
            defaultOutputDirpath = fullfile(defaultOutputDirpath,'session');
        catch
            defaultOutputDirpath = DBM4.UI.default_output_path('Sessions');

%             defaultOutputDirpath = dbmOSW.get_default_export_dirpath('session');
        end
        import DBM4.Export.create_light_struct;
        dbmODW.DBMMainstruct =  create_light_struct(dbmStruct);
        export_dbm_session_struct_mat(dbmODW, dbmOSW, defaultOutputDirpath);  
    end

    function [] = export_raw_kymos(src,event)
        if ~isfield(sets,'choose_output_folder')
            sets.choose_output_folder = 1;
        end
        try
            dbmOSW.DBMSettingsstruct = sets;
        catch
        end

        if sets.choose_output_folder==1
            try
                [defaultOutputDirpath,~] = fileparts(dbmOSW.DBMSettingsstruct.movies.movieNames{1});
                outputDirpath = fullfile(defaultOutputDirpath,'raw_kymo');
                [~,~] = mkdir(outputDirpath);
            catch
                defaultOutputDirpath = DBM4.UI.default_output_path('RawKymos');

%                 defaultOutputDirpath = dbmOSW.get_default_export_dirpath('raw_kymo');
                outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Raw Kymo Files');
            end
        else
            outputDirpath = sets.outputDirpath;
        end
        
                
        files = cellfun(@(rawKymo, outputKymoFilepath)...
        isfile(fullfile(outputDirpath,outputKymoFilepath)),...
        dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
        
        if sum(files) > 0
            cellfun(@(rawKymo, outputKymoFilepath)...
            delete(fullfile(outputDirpath,outputKymoFilepath)),...
            dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
        end

        % save 1) enhanced 2) kymo 3) enhanced
        if ~isfield(dbmStruct.kymoCells,'enhanced')
             dbmStruct.kymoCells.enhanced =  cellfun(@(rawKymo) imadjust(rawKymo/max(rawKymo(:)),[0.1 0.95]),dbmStruct.kymoCells.rawKymos,'un',false);
        end
         cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(round(double(rawKymo)./max(rawKymo(:))*2^16)), fullfile(outputDirpath,outputKymoFilepath), 'tif','WriteMode','append'),...
        dbmStruct.kymoCells.enhanced, dbmStruct.kymoCells.rawKymoName);

        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif','WriteMode','append'),...
        dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
    
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif','WriteMode','append'),...
        dbmStruct.kymoCells.rawBitmask, dbmStruct.kymoCells.rawKymoName);

        disp(['Kymo data saved at ',defaultOutputDirpath ])

        %% extra for re-calc
        sets.loaded_raw_kymos_from_files = 1; % in case we need to check later
        try
            splitName = strsplit(dbmStruct.kymoCells.rawKymoName{1},'raw_kymo');
            sets.kymofold = splitName{1};
        catch
        end
    end
    
    function [] = export_aligned_kymos(src, event)
        import OldDBM.General.Export.export_aligned_kymos;

        try
            [defaultOutputDirpath,~] = fileparts(dbmOSW.DBMSettingsstruct.movies.movieNames{1});
            outputDirpath = fullfile(defaultOutputDirpath,'aligned_kymo');
            [~,~] = mkdir(outputDirpath);
        catch
            defaultOutputDirpath = DBM4.UI.default_output_path('AlignedKymos');

%             defaultOutputDirpath = dbmOSW.get_default_export_dirpath('aligned_kymo');
            outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Aligned Kymo Files');
        end
    
        if  ~isfield(dbmStruct.kymoCells,'alignedKymos') % have to calculate aligned kymographs
            display_aligned_kymographs;
        end

        % check if kymos are aligned
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
        dbmStruct.kymoCells.alignedKymos, dbmStruct.kymoCells.alignedNames);
    
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
        dbmStruct.kymoCells.alignedBitmasks, dbmStruct.kymoCells.alignedNamesBitmask);
    end

    function [] = export_pngs(src, event)
    
        if ~isfield(dbmStruct.kymoCells,'kymoStatsTable')
            calculate_lengths;
%             [dbmStruct.kymoCells.kymoStatsTable] = run_calculate_lengths(sets);
        end
        defaultStatsOutputDirpath =   fullfile(fileparts(sets.movies.movieNames{1}),'pngs');

        [~,~] = mkdir(defaultStatsOutputDirpath);

        import DBM4.Figs.disp_rect_image; % new plot to display annotated image
        import DBM4.plot_kymo_edges;

%         tic
        for jj=1:length(dbmStruct.kymoCells.rawKymos)
            f = figure('Visible','off');
            hAxis = axes(f);
            
            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
            disp_rect_image(hAxis, dbmStruct.kymoCells.rawKymos{jj}, strrep(fe,'_','\_'))
     
            hAxis.YDir = 'reverse'; % show kymo's flowing down

            hold on
            set(gca,'color',[0 0 0]);
            set(hAxis,'XTick',[]);
            set(hAxis,'YTick',[]);

            plot_kymo_edges(hAxis,...
            dbmStruct.kymoCells.kymosMoleculeLeftEdgeIdxs{jj}', ...
            dbmStruct.kymoCells.kymosMoleculeRightEdgeIdxs{jj}');
                axisFrame = getframe(hAxis);
            axisImg = frame2im(axisFrame);
            imwrite(axisImg, fullfile(defaultStatsOutputDirpath,strrep(dbmStruct.kymoCells.rawKymoName{jj},'.tif','.png')));
%             saveas(f, fullfile(defaultStatsOutputDirpath,strrep(dbmStruct.kymoCells.rawKymoName{jj},'.tif','.png')));

        end
% toc
    
%         cellfun(@(rawKymo, outputKymoFilepath)...
%         imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif'),...
%         dbmStruct.kymoCells.alignedBitmasks, dbmStruct.kymoCells.alignedNamesBitmask);
    end
    
    function [] = export_time_averages_kymos(src, event)

        try
            [defaultOutputDirpath,~] = fileparts(dbmOSW.DBMSettingsstruct.movies.movieNames{1});
            outputDirpath = fullfile(defaultOutputDirpath,'aligned_kymo_time_avg');
            [~,~] = mkdir(outputDirpath);
        catch
            defaultOutputDirpath = dbmOSW.get_default_export_dirpath('aligned_kymo_time_avg');
            outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Barcode .mat files');
        end
       
        if  ~isfield(dbmStruct.kymoCells,'barcodes') % have to calculate aligned kymographs
            display_time_averages;
        end

        cellfun(@(rawBarcode, outputKymoFilepath)...
        save( fullfile(outputDirpath,strrep(outputKymoFilepath,'.tif','.mat')), 'rawBarcode'),...
        dbmStruct.kymoCells.barcodes, dbmStruct.kymoCells.alignedNames);
    
        % todo: add bitmask to make this hca'esque, single file, so it can
        % be loaded in HCA.        
    end


    % loading session data / only from new DBM
    function load_session_data(src, event)
        defaultSessionDirpath = DBM4.UI.default_output_path('Sessions');

%         defaultSessionDirpath = dbmOSW.get_default_import_dirpath('session');

        import OldDBM.General.Import.try_prompt_single_session_filepath;
        sessionFilepath = try_prompt_single_session_filepath(defaultSessionDirpath);

        if isempty(sessionFilepath)
            return;
        end

        dbmODW = load(sessionFilepath);
        
        sets = dbmODW.DBMSettingsstruct;
        dbmStruct = dbmODW.DBMMainstruct;

        if isfield(dbmStruct,'fileCell')
            import DBM4.UI.load_all_session_data;
            dbmStruct = load_all_session_data(dbmStruct);
         
        end
        

        show_home();
    end


    function load_kymo_data(src,event)
        dbmStruct = [];
        
%         defaultSessionDirpath = dbmOSW.get_default_import_dirpath('session');
% 
        import OldDBM.General.Import.import_raw_kymos;
        [dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName,...
            dbmStruct.kymoCells.rawBitmask,dbmStruct.kymoCells.enhanced]  = import_raw_kymos();

        sets.loaded_raw_kymos_from_files = 1;
        try % if kymos are save in raw_kymo, this is suitable for recalc
            splitName = strsplit(dbmStruct.kymoCells.rawKymoName{1},'raw_kymo');
            sets.kymofold = splitName{1};
        catch
        end
        sets.rawMovieDirPath = sets.kymofold;

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

%         show_home(); 
    end


    function display_raw_kymographs(src, event)
    % 1: verify information score & length, etc. threshold
        
        numP = ceil(sqrt(length(dbmStruct.kymoCells.rawKymos)));
        hPanelRawKymosTile = tiledlayout(hPanelRawKymos,numP,numP,'TileSpacing','tight','Padding','tight');

        import DBM4.Figs.disp_rect_image;

        for jj=1:length(dbmStruct.kymoCells.rawKymos)
            hAxis = nexttile(hPanelRawKymosTile);

            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
            disp_rect_image(hAxis, dbmStruct.kymoCells.rawKymos{jj}, strrep(fe,'_','\_'));
            hAxis.YDir = 'reverse'; % show kymo's flowing down
        end
        tsHCC.SelectedTab = hPanelRawKymos;
        % todo: allow selecting kymo's in this window
    end

    function display_aligned_kymographs(src, event)
        numK = length(dbmStruct.kymoCells.rawKymos);
        numP = ceil(sqrt(numK));

        if ~isfield(dbmStruct.kymoCells,'alignedKymos')
            import OptMap.KymoAlignment.NRAlign.nralign;
            for ix=1:numK
                    fprintf('Aligning kymograph for file molecule #%d of #%d ...\n', ix, numK);
                    [alignedKymo, stretchFactorsMat, shiftAlignedKymo] = nralign(dbmStruct.kymoCells.rawKymos{ix},false,dbmStruct.kymoCells.rawBitmask{ix});
                    dbmStruct.kymoCells.alignedKymos{ix} = alignedKymo;
                    dbmStruct.kymoCells.alignedBitmasks{ix} = ~isnan(alignedKymo);
                    dbmStruct.kymoCells.stretchFactorsMat{ix} = stretchFactorsMat;
                    dbmStruct.kymoCells.shiftAlignedKymo{ix} = shiftAlignedKymo;     
                    dbmStruct.kymoCells.alignedNames{ix} =  strrep(dbmStruct.kymoCells.rawKymoName{ix},'_kymograph','_alignedkymograph');
                    dbmStruct.kymoCells.alignedNamesBitmask{ix} =  strrep(dbmStruct.kymoCells.rawBitmaskName{ix},'_bitmask','_alignedbitmask');
            end 
        end
           
        import DBM4.Figs.disp_rect_image;

        hPanelAlignedKymosTile = tiledlayout(hPanelAlignedKymos,numP,numP,'TileSpacing','none','Padding','none');
        for jj=1:numK
            hAxis = nexttile(hPanelAlignedKymosTile);
            hAxis.YDir = 'reverse'; % show kymo's flowing down

            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
            disp_rect_image(hAxis, dbmStruct.kymoCells.alignedKymos{jj}, strrep(fe,'_','\_'));

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
                try
                    bitmask = dbmStruct.kymoCells.alignedMask{ix};
                catch
                    bitmask = ~isnan(dbmStruct.kymoCells.alignedKymos{ix});
                end
                dbmStruct.kymoCells.fgStartIdxs{ix} = arrayfun(@(x) find(bitmask(x,:),1,'first'),1:size(bitmask,1));
                dbmStruct.kymoCells.fgEndIdxs{ix} = arrayfun(@(x) find(bitmask(x,:),1,'last'),1:size(bitmask,1));
                dbmStruct.kymoCells.fgStartIdxsMean(ix) = round(mean( dbmStruct.kymoCells.fgStartIdxs{ix}));
                dbmStruct.kymoCells.fgEndIdxsMean(ix) = round(mean(  dbmStruct.kymoCells.fgEndIdxs{ix}));
            end
        end
        
        hPanelTimeAveragesTile = tiledlayout(hPanelTimeAverages,numP,numP,'TileSpacing','none','Padding','none');
        import DBM4.Figs.plot_aligned_kymo_time_avg;

%                   set(gca,'XTick',[])
%             set(gca,'YTick',[])
        for jj=1:numK
            hAxis = nexttile(hPanelTimeAveragesTile);
            hold on
            set(gca,'color',[0 0 0]);
            [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
            plot_aligned_kymo_time_avg(hAxis, fe,  dbmStruct.kymoCells.fgStartIdxsMean(jj), dbmStruct.kymoCells.fgEndIdxsMean(jj),...
                dbmStruct.kymoCells.barcodes{jj} , dbmStruct.kymoCells.barcodesStd{jj}, dbmStruct.kymoCells.numsKymoFrames(jj));

        end
%         axtoolbar(hAxis,{'zoomin','zoomout','restoreview'});
%         ax = gca;
%         ax.Toolbar.Visible = 'on';
        tsHCC.SelectedTab = hPanelTimeAverages; 
 
    end

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
        
        sets.movies.movieNames = cellfun(@(x) fullfile(dbmStruct.rawMovieDirPath ,x), dbmStruct.rawMovieFilenames,'un',false);

        % Now run main algorithm: High-Precision-Fluorophore-Localization
        import Core.hpfl_extract;
        [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(sets);

        show_home();

    end


    function SelectedConvertToTif(src, event)
            disp('Select files to convert to tif')
            import DBM4.convert_czi_to_tif;
            convert_czi_to_tif;  
    end
    
        function [sets,tsHCC,textList,textListT,itemsList,...
               hHomeScreen, hPanelRawKymos,hPanelAlignedKymos,hPanelTimeAverages,hAdditional,tshAdd] = generate_gui()
      
            mFilePath = mfilename('fullpath');
            mfolders = split(mFilePath, {'\', '/'});
            versionLLDEV = importdata(fullfile(mfolders{1:end-3},'VERSION'));

            hFig = figure('Name', ['DNA Barcode Matchmaker v' versionLLDEV{1}], ...
                'Units', 'normalized', ...
                'OuterPosition', [0.05 0.1 0.8 0.8], ...
                'NumberTitle', 'off', ...     
                'MenuBar', 'none',...
                'ToolBar', 'none' ...
            );
            m = uimenu('Text','DBM');
            cells1 = {'Import','Export','Kymographs','Statistics','Convert czi to tif','Pipelines'};
            mSub = cellfun(@(x) uimenu(m,'Text',x),cells1,'un',false);
            mSub{5}.MenuSelectedFcn = @SelectedConvertToTif;


            cellsImport = {'Load Session Data','Convert czi to tif','Load Movie(s) (tif format)','Load Raw Kymograph(s)'};

            cellsExport = {'Save Session Data','Raw kymographs','Aligned Kymographs','Time Averages','Pngs with edges','Session Data (light)'};
            cellsKymographs = {'Display Raw kymographs','Display Aligned Kymographs','Plot Time Averages','Display lambdas','Filter molecules'};
            cellsStatistics = {'Calculate molecule lengths and intensities','Calculate Raw Kymos Center of Mass','Plot length vs intensity'};
            cellsPipelines = {'Genome assembly','Lambda lengths','Lambda recalc','Good/bad tool'};

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
            mSubExport{5}.MenuSelectedFcn = @export_pngs;

            mSubExport{6}.MenuSelectedFcn = @save_light_session_data;


            mSubKymographs{1}.MenuSelectedFcn = @display_raw_kymographs;
            mSubKymographs{2}.MenuSelectedFcn = @display_aligned_kymographs;
            mSubKymographs{3}.MenuSelectedFcn = @display_time_averages;
            mSubKymographs{4}.MenuSelectedFcn = @display_lambdas;
            mSubKymographs{5}.MenuSelectedFcn = @filter_molecules;

            mSubStatistics{1}.MenuSelectedFcn = @calculate_lengths;
            mSubStatistics{2}.MenuSelectedFcn = @calculate_com;
%             set(  mSubStatistics{2}, 'Enable', 'off');

            mSubStatistics{3}.MenuSelectedFcn = @calculate_length_intensity_plot;


            mSubPipelines = cellfun(@(x) uimenu(mSub{6},'Text',x),cellsPipelines,'un',false);
            mSubPipelines{1}.MenuSelectedFcn = @genome_assembly_pipeline;
            mSubPipelines{2}.MenuSelectedFcn = @detect_lambda_lengths_pipeline;
            mSubPipelines{3}.MenuSelectedFcn = @detect_lambda_lengths_recalc;
            mSubPipelines{4}.MenuSelectedFcn = @good_bad_recalc;

%             set( mSubPipelines{3}, 'Enable', 'off');

%             mSubPipelines{3}.MenuSelectedFcn = @scattering_microscopy_pipeline;


%             set( mSubPipelines{1}, 'Enable', 'on');

            
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
            hAdditional.lengthPlot = uitab(tshAdd, 'title',strcat('length vs int'));
            hAdditional.Re = uitab(tshAdd, 'title',strcat('Re'));

        % set(hHomeScreen,'Visible','off')
            sets =  dbmOSW.DBMSettingsstruct;

                % Put the loaded settings into the GUI.
                    % make into loop
            checkItems =  {'Molecule angle calculation (skip if angle is known)','Single frame molecule detection','Denoise (Experimental)','Detect short molecules','Keep bad molecules'};
            checkValues = [sets.moleculeAngleValidation  sets.timeframes  sets.denoise, sets.detectlambdas sets.keepBadEdgeMols ] ;
           % checkbox for things to plot and threshold
            for i=1:length(checkItems)
                itemsList{i} = uicontrol('Parent', hPanelImport, 'Style', 'checkbox','Value',checkValues(i),'String',{checkItems{i}},'Units', 'normal', 'Position', [0.45 .83-0.05*i 0.3 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            end
            set(itemsList{2}, 'Enable', 'off');

            % parameters with initial values
           textItems =  {'averagingWindowWidth (px)','nmPerPixel (nm/px)','distbetweenChannels',...
               'Max number frames (0-all)','stdDifPos (variation in edge position)','numPts (for detecting)','minLen (post-processing)','sigma (1-4, strickness of edge det.)','angle', '+-minAngle (degrees)'};
           values =  {num2str(sets.averagingWindowWidth),num2str(sets.nmPerPixel),...
               num2str(sets.distbetweenChannels),...
               num2str(sets.max_number_of_frames),num2str(sets.stdDifPos), num2str(sets.numPts),num2str(sets.minLen),num2str(sets.SigmaLambdaDet),num2str(sets.initialAngle), num2str(sets.minAngle)};

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
%             set(textList{8}, 'Enable', 'off');
%             set(textList{6}, 'Enable', 'off');


            runButton = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Save settings'},'Callback',@save_settings,'Units', 'normal', 'Position', [0.7 0.4 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            clearButton = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Restore settings'},'Callback',@restore_settings,'Units', 'normal', 'Position', [0.7 0.3 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            reRunButton = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Re-run analysis'},'Callback',@re_run,'Units', 'normal', 'Position', [0.7 0.2 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]
            reRunFiltering = uicontrol('Parent', hPanelImport, 'Style', 'pushbutton','String',{'Re-run filtering kymos'},'Callback',@re_run_filtering,'Units', 'normal', 'Position', [0.7 0.1 0.2 0.05]);%, 'Max', Inf, 'Min', 0);  [left bottom width height]

        end
    
    function calculate_lengths(src, event)
        import OldDBM.Kymo.UI.prompt_kymo_analysis_method;
        [kymoAnalysisMethod, sets.shouldSaveTF] = prompt_kymo_analysis_method();
        
        sets.skipEdgeDetection = false;
        sets.skipDoubleTanhAdjustmentTF = true;
        sets.double_tanh_edge_detection = false;
        switch kymoAnalysisMethod
            case 'kymo_edge'
                sets.skipEdgeDetection = true;
            case 'basic_otsu_edge_detection'
                sets.basic_otsu_edge_detection = true;
            case 'double_tanh_edge_detection'
                sets.double_tanh_edge_detection = true;
            otherwise
                disp('Method not implemented')
                return;
        end

        %         import DBM4.run_calc_plot_save_kymo_analysis;
        if ~isfield(dbmStruct.kymoCells,'kymoStatsTable')
            [dbmStruct.kymoCells.kymoStatsTable] = run_calculate_lengths(sets);
        end

        % plot
        if sets.shouldSaveTF==0 % only plot if not saving
            numP = ceil(sqrt(length(dbmStruct.kymoCells.rawKymos)));
            hPanelRawKymosTile = tiledlayout(hAdditional.length,numP,numP,'TileSpacing','none','Padding','none');
    
    
            for jj=1:length(dbmStruct.kymoCells.rawKymos)
                hAxis = nexttile(hPanelRawKymosTile);
                hAxis.YDir = 'reverse'; % show kymo's flowing down
    
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
                        dbmStruct.kymoCells.kymoStatsTable.moleculeLeftEdgeIdxs{jj}', ...
                        dbmStruct.kymoCells.kymoStatsTable.moleculeRightEdgeIdxs{jj}');
            
    %             disp_rect_annotated_image(, fe, {});
    
            end
            tsHCC.SelectedTab = hAdditional.hAdd;
        end
    end

function [kymoStatsTable] = run_calculate_lengths(sets)
    %
    %   Args:
    %       sets - whether to generate things
    %
    %   Returns:
    %       kymoStatsTable - kymo statistics table
    %
    % TODO:
    
    % %     % generate
    import DBM4.run_kymo_analysis;
    [kymoStatsTable,moleculeMasks] = run_kymo_analysis(dbmStruct.kymoCells, sets);

    if ~isfield(dbmStruct.kymoCells,'rawBitmask')
        dbmStruct.kymoCells.rawBitmask = moleculeMasks';
    end
    % % 
    try
        defaultStatsOutputDirpath =   fileparts(sets.movies.movieNames{1});
    catch
        defaultStatsOutputDirpath = pwd;
    end
    % %     
    if sets.shouldSaveTF
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

            % todo: if time-frame size different, returns error
            
            csvFilename = strrep(statsOutputMatFilepath,'.mat','.csv');
            numRows = size(kymoStatsTable, 1);
            fun = @(x) {['moleculeLeftEdgeIdxs_',x],['moleculeRightEdgeIdxs_',x],['framewiseMoleculeExts_',x],['meanFramewiseMoleculeIntensity_',x],...
            ['stdFramewiseMoleculeIntensity_',x]};
            % if tables the same length, if not this will give issue
            fT = cell2mat(arrayfun(@(rowIdx) [kymoStatsTable{rowIdx, 'moleculeLeftEdgeIdxs'}{1},kymoStatsTable{rowIdx, 'moleculeRightEdgeIdxs'}{1}, kymoStatsTable{rowIdx, 'framewiseMoleculeExts'}{1},...
            kymoStatsTable{rowIdx, 'meanFramewiseMoleculeIntensity'}{1},kymoStatsTable{rowIdx, 'stdFramewiseMoleculeIntensity'}{1}],1:numRows,'un',false));
            allnames = (arrayfun(@(rowIdx) fun(num2str(rowIdx)),1:numRows,'un',false));
            framewiseStatsTable = array2table(fT,'VariableNames',[allnames{:}]);
            writetable(framewiseStatsTable, csvFilename);

        end
    end
end


function calculate_length_intensity_plot(src, event)
    % Plots length vs intensity and marks potential lambda molecules based on
    % pre-selected window
    if ~isfield(dbmStruct.kymoCells,'kymoStatsTable')
        calculate_lengths();
    end
    
%     axes(hAdditional.lengthPlot)
    import DBM4.Figs.length_vs_intensity;
    length_vs_intensity(dbmStruct.kymoCells.kymoStatsTable,hAdditional.lengthPlot);

     tsHCC.SelectedTab = hAdditional.hAdd;
end



% lambda pipeline
function detect_lambda_lengths_pipeline(src, event)
    % runs the detect_lambdas pipeline   
    userDir = uigetdir(pwd,'Select a single directory with movies to run through lambda pipeline');
    import DBM4.LambdaDet.run_lambda_lengths_pipeline;
    
    [dbmStruct,~] = run_lambda_lengths_pipeline(userDir,sets);
%     restore_settings(sets)
end


function good_bad_recalc(src, event)
    % runs the detect_lambdas pipeline   
%     userDir = uigetdir(pwd,'Select directory with movies to run through lambda pipeline');
    import Microscopy.UI.UserSelection.good_bad_recalc;
    tsHCC.SelectedTab = hAdditional.hAdd;
%     hAdditional
    tshAdd.SelectedTab = hAdditional.Re;

    if ~sets.loaded_raw_kymos_from_files 
        export_raw_kymos();% force export raw kymos
    else
        sets.rawMovieDirPath = sets.kymofold;
    end
    good_bad_recalc(sets,dbmStruct,hAdditional);
end

function detect_lambda_lengths_recalc(src, event)
    % runs the detect_lambdas pipeline   
%     userDir = uigetdir(pwd,'Select directory with movies to run through lambda pipeline');
    import DBM4.LambdaDet.run_lambda_lengths_pipeline_recalc;
    tsHCC.SelectedTab = hAdditional.hAdd;
%     hAdditional
    tshAdd.SelectedTab = hAdditional.Re;
    run_lambda_lengths_pipeline_recalc(sets,dbmStruct,hAdditional);
end

% genome assembly pipeline
function genome_assembly_pipeline(src, event)
    userDir = uigetdir(pwd,'Select directory with movies to run through bargrouping pipeline');
    import DBM4.GenomAs.run_genome_assembly_pipeline;
    run_genome_assembly_pipeline(userDir);

end

function scattering_microscopy_pipeline(src, event)
    % runs the detect_lambdas pipeline   
    userDir = uigetfile(pwd,'Select .mat files to run through scattering microscopy pipeline','MultiSelect','on');
    import DBM4.Scattering.scattering_microscopy_pipeline;
    
    scattering_microscopy_pipeline(userDir,sets);
end


function [] = calculate_com(src, event)
    if nargin < 3
        writeToTSV = true;
    end
    % todo..
    import DBM4.calc_raw_kymos_centers_of_mass;
    centerOfMassTable = calc_raw_kymos_centers_of_mass(dbmStruct.kymoCells);
    disp(centerOfMassTable);

%     import OldDBM.Kymo.Core.calc_raw_kymos_centers_of_mass;
%     [centerOfMassTable] = calc_raw_kymos_centers_of_mass(dbmODW);
%     disp(centerOfMassTable);
% 
    if writeToTSV
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
         defaultOutputDirpath = DBM4.UI.default_output_path('raw_kymo_center_of_mass');
%         defaultOutputDirpath = dbmOSW.get_default_export_dirpath('raw_kymo_center_of_mass');
        defaultOutputFilename = sprintf('centerOfMassTable_%s.tsv', timestamp);
        defaultOutputFilepath = fullfile(defaultOutputDirpath, defaultOutputFilename);

        [outputFilename, outputDirpath] = uiputfile('*.tsv', 'Save Centers of Mass As', defaultOutputFilepath);

        if isequal(outputDirpath, 0)
            return;
        end
        outputFilepath = fullfile(outputDirpath, outputFilename);

        writetable(centerOfMassTable, outputFilepath, ...
            'Delimiter', sprintf('\t'), ...
            'FileType', 'text');
    end


    end
end