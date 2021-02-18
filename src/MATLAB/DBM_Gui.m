function [] = DBM_Gui(useGUI,dbmOSW)
    % DBM_GUI - DNA Barcode Matchmaker (DBM) for nanochannels GUI
    

    if nargin < 2
        % Get default settings path
        import OldDBM.General.SettingsWrapper;
        defaultSettingsFilepath = SettingsWrapper.get_default_DBM_ini_filepath();
        if not(exist(defaultSettingsFilepath, 'file'))
        defaultSettingsFilepath = '';
        end
        dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);
    end
    
    if nargin >=1
        dbmOSW.DBMSettingsstruct.useGUI = useGUI;  
    end

    if dbmOSW.DBMSettingsstruct.useGUI
        % old method from prior 4.1.0, which uses GUI to import and
        % manipulate movies
        hFig = figure(...
            'Name', 'DNA Barcode Matchmaker', ...
            'Menubar', 'none', ...
            'NumberTitle', 'off', ...
            'Units','normalized', ...
            'Outerposition', [0.05, 0.05, 0.9, 0.9]);
        hMenuParent = hFig;

        hPanel = uipanel('Parent', hFig);
        import Fancy.UI.FancyTabs.TabbedScreen;
        ts = TabbedScreen(hPanel);


        hTabDBM = ts.create_tab('DBM');
        ts.select_tab(hTabDBM);
        hPanelDBM = uipanel('Parent', hTabDBM);
        tsDBM = TabbedScreen(hPanelDBM);

        import OldDBM.UI.add_dbm_menu;
        add_dbm_menu(hMenuParent, tsDBM,dbmOSW);
    else
        % new method, HCA'esque, which prompts for user relevant files only
        % when required
        sets = dbmOSW.DBMSettingsstruct;
   
        if sets.askForDBMtoolSettings
            prompt = {'dbmtool','averagingWindowWidth', 'rowSidePadding', 'distbetweenChannels','filterEdgeMolecules', 'filterCloseMolecules', 'minMoleculeLength', 'minMoleculeSize','denoise'};
            title = 'DBM 4.1 (no-gui) settings';
            dims = [1 35];
            definput = {'corr','3','100','7','1','0','20','20','0'};
            answer = inputdlg(prompt,title,dims,definput);

            sets.dbmtool = answer{1};
            sets.averagingWindowWidth = str2double(answer{2});
            sets.rowSidePadding = str2double(answer{3});
            sets.distbetweenChannels = str2double(answer{4});
            sets.filterEdgeMolecules = str2double(answer{5});
            sets.filterCloseMolecules = str2double(answer{6});
            sets.minMoleculeLength = str2double(answer{7}); % skips edge detection and assumes the first
            % non-zero and last nonzero to be edges of molecule
            sets.random.generate = str2double(answer{8});
            sets.movies.denoise =  str2double(answer{9});
    
   
        end
        
     
%         %whether to use old or new DBM
        switch sets.dbmtool
            case 'old'
                dbmOSW.DBMSettingsstruct = sets;

                 import OldDBM.General.Import.import_movies;
                [fileCells, fileMoleculeCells, pixelsWidths_bps] = import_movies([],dbmOSW);     
            case 'corr'
                % maybe make these into "cases"
                import DBM4.import_movies;
                %         import OldDBM.General.Import.import_movies;
                [fileCells, fileMoleculeCells, pixelsWidths_bps] = DBM4.import_movies(sets);     
            otherwise
                % default to something..
        end

        import OldDBM.General.DataWrapper;
        dbmODW = DataWrapper();    
        dbmODW.DBMMainstruct.fileCell = fileCells;
        dbmODW.DBMMainstruct.fileMoleculeCell = fileMoleculeCells;
        import OldDBM.General.Export.export_dbm_session_struct_mat;
        defaultOutputDirpath = dbmOSW.get_default_export_dirpath('session');
        export_dbm_session_struct_mat(dbmODW, dbmOSW, defaultOutputDirpath);

        % load session stuff
        hFig = figure(...
            'Name', 'DNA Barcode Matchmaker', ...
            'Menubar', 'none', ...
            'NumberTitle', 'off', ...
            'Units','normalized', ...
            'Outerposition', [0.05, 0.05, 0.9, 0.9]);
        hMenuParent = hFig;

        hPanel = uipanel('Parent', hFig);
        import Fancy.UI.FancyTabs.TabbedScreen;
        ts = TabbedScreen(hPanel);


        hTabDBM = ts.create_tab('DBM');
        ts.select_tab(hTabDBM);
        hPanelDBM = uipanel('Parent', hTabDBM);
        tsDBM = TabbedScreen(hPanelDBM);

        import DBM4.add_dbm_menu;
        DBM4.add_dbm_menu(hMenuParent, tsDBM,dbmOSW,dbmODW);

        % Now: show DBM with the output
           
    end
end

% 