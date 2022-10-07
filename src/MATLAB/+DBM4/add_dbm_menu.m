function [] = add_dbm_menu(hMenuParent, tsDBM,dbmOSW,dbmODW)

    if nargin < 3
        % Get default settings path
        import OldDBM.General.SettingsWrapper;
        defaultSettingsFilepath = SettingsWrapper.get_default_DBM_ini_filepath();
        if not(exist(defaultSettingsFilepath, 'file'))
            defaultSettingsFilepath = '';
        end
        dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);
    end
    
    if nargin < 4
        import OldDBM.General.DataWrapper;
        dbmODW = DataWrapper();
    end

    %Create UI TAB
    hMenuDBM = uimenu( ...
        'Parent', hMenuParent, ...
        'Label', 'DBM');

    % Import menu
    hMenuImport = uimenu( ...
        'Parent', hMenuDBM, ...
        'Label','&Import');
    uimenu( ...
        'Parent', hMenuImport, ...
        'Label', 'Load Session Data', ...
        'Callback', @(~, ~) on_load_sess_data(dbmODW, dbmOSW, tsDBM));
    uimenu( ...
        'Parent', hMenuImport, ...
        'Label', 'Load Movie(s) (tif-format)', ...
        'Callback', @(~, ~) on_load_movies(dbmODW, dbmOSW, tsDBM), 'Accelerator', 'L');
    uimenu( ...
        'Parent', hMenuImport, ...
        'Label', 'Load Raw Kymograph(s)', ...
        'Callback', @(~, ~) on_load_raw_kymos(dbmODW, dbmOSW, tsDBM));

    % Export menu
    import OldDBM.General.Export.DataExporter;
    dbmDE = DataExporter(dbmODW, dbmOSW);
    hMenuExport = uimenu( ...
        'Parent', hMenuDBM, ...
        'Label', '&Export');
    uimenu( ...
        'Parent', hMenuExport, ...
        'Label', 'Save Session Data', ...
        'Callback', {@(~, ~) dbmDE.export_dbm_session_struct_mat()});
    uimenu( ...
        'Parent', hMenuExport, ...
        'Label', 'Raw Kymographs', ...
        'Callback', @(~, ~) dbmDE.export_raw_kymos());
    uimenu( ...
        'Parent', hMenuExport, ...
        'Label', 'Aligned Kymographs', ...
        'Callback', @(~, ~) dbmDE.export_aligned_kymos());
    uimenu( ...
        'Parent', hMenuExport, ...
        'Label', 'Time Averages', ...
        'Callback', ...
        @(~, ~) dbmDE.export_aligned_kymo_time_avs());
    % uimenu( ...
    %     'Parent', hMenuExport, ...
    %     'Label', 'Molecule Statistics', ...
    %     'Callback', @(~, ~) DBM_Gui.export_molecule_analyses(dbmODW, dbmOSW));

    % Settings menu: better to change DBM.ini, so we are certain what
    % settings are loaded, user selection might results in
    % errors/mistyping.
    %     % Settings menu
    %     hMenuSettings = uimenu( ...
    %         'Parent', hMenuDBM, ...
    %         'Label','&Change Settings');
    %     uimenu( ...
    %         'Parent', hMenuSettings, ...
    %         'Label', 'Update Filter Settings', ...
    %         'Callback', {@(~, ~) dbmODW.update_filter_settings()});


    % Kymographs menu
    hMenuKymographs = uimenu( ...
        'Parent', hMenuDBM, ...
        'Label','&Kymographs');

    uimenu( ...
        'Parent', hMenuKymographs, ...
        'Label', 'Display &Raw Kymographs', ...
        'Callback', @(~, ~) on_display_raw_kymos(dbmODW, tsDBM), ...
        'Accelerator', 'R');
    uimenu( ...
        'Parent', hMenuKymographs, ...
        'Label', 'Display &Aligned Kymographs', ...
        'Callback', @(~, ~) on_display_aligned_kymos(dbmODW, tsDBM), ...
        'Accelerator', 'A');
    uimenu( ...
        'Parent', hMenuKymographs, ...
        'Label', 'Plot Time Averages', ...
        'Callback', @(~, ~) on_plot_kymo_time_averages(dbmODW, tsDBM), ...
        'Accelerator', 'T');

    % Statistics menu
    hMenuStatistics = uimenu( ...
        'Parent', hMenuDBM, ...
        'Label', '&Statistics');
    uimenu( ...
        'Parent', hMenuStatistics, ...
        'Label', 'Calculate molecule lengths and intensities', ...
        'Callback', @(~, ~) on_calc_molecule_lengths_and_intensity(dbmODW, tsDBM,dbmOSW));

    import OldDBM.Kymo.UI.disp_raw_kymos_centers_of_mass;
    uimenu( ...
        'Parent', hMenuStatistics, ...
        'Label', 'Calculate Raw Kymo Centers of Mass', ...
        'Callback', @(~, ~) disp_raw_kymos_centers_of_mass(dbmODW, dbmOSW));

    % uimenu( ...
    %     'Parent', hMenuStatistics, ...
    %     'Label','Plot Molecule Lengths', ...
    %     'Callback', @(~, ~) on_plot_molecule_lengths_hist(dbmODW, tsDBM));
    % 
    % uimenu( ...
    %     'Parent', hMenuStatistics, ...
    %     'Label','Plot InfoScore Hists', ...
    %     'Callback', @(~, ~) on_plot_infoscore_hist(dbmODW, tsDBM));
    
    if nargin == 4
        on_update_home_screen(dbmODW, tsDBM);
    end
    
    function [sessionGui] = get_session_object(tsDBM)
        hasValidGuiTF = tsDBM.has_valid_gui();
        if not(hasValidGuiTF)
            error('GUI not found');
            % sessionGui = struct();
            % return;
        end
        [menuSessionUUID, foundValueTF] = tsDBM.get_data('DBM_MenuSession_UUID');
        if not(foundValueTF)
            menuSessionUUID = char(java.util.UUID.randomUUID());
            tsDBM.set_data('DBM_MenuSession_UUID', menuSessionUUID);
        end
        
        persistent pSessionGuisMap;
        if not(isa(pSessionGuisMap, 'containers.Map'))
            pSessionGuisMap = containers.Map();
        end
        if isKey(pSessionGuisMap, menuSessionUUID)
            sessionGui = pSessionGuisMap(menuSessionUUID);
        else
            sessionGui = struct();
            pSessionGuisMap(menuSessionUUID) = sessionGui;
        end
        sessionGui.save_updates = @save_updates;
        
        function save_updates(updatedSessionGui)
            updatedSessionGui = rmfield(updatedSessionGui, 'save_updates');
            pSessionGuisMap(menuSessionUUID) = updatedSessionGui;
        end
    end
    
    function [] = on_update_home_screen(dbmODW, tsDBM)
        sessionGui = get_session_object(tsDBM);
        
        if not(isfield(sessionGui, 'hPanelHomescreen'))
            sessionGui.hPanelHomescreen = [];
        end
        if not(isfield(sessionGui, 'hTabHomescreen'))
            sessionGui.hTabHomescreen = [];
        end
        
        hPanelHomescreen = sessionGui.hPanelHomescreen;
        hTabHomescreen = sessionGui.hTabHomescreen;
        if isempty(hPanelHomescreen) || not(isvalid(hPanelHomescreen))
            hTabHomescreen = tsDBM.create_tab('HomeScreen');
            hPanelHomescreen = uipanel('Parent', hTabHomescreen);
        end
        sessionGui.hTabHomescreen = hTabHomescreen;
        sessionGui.hPanelHomescreen = hPanelHomescreen;
        sessionGui.save_updates(sessionGui);
        
        tsDBM.select_tab(hTabHomescreen);

        import OldDBM.General.UI.show_home_screen;
        show_home_screen(dbmODW, hPanelHomescreen);
    end

    function [] = on_display_raw_kymos(dbmODW, tsDBM)
        sessionGui = get_session_object(tsDBM);
        
        if not(isfield(sessionGui, 'hPanelRawKymos'))
            sessionGui.hPanelRawKymos = [];
        end
        if not(isfield(sessionGui, 'hTabRawKymos'))
            sessionGui.hTabRawKymos = [];
        end
        hPanelRawKymos = sessionGui.hPanelRawKymos;
        hTabRawKymos = sessionGui.hTabRawKymos;
        
        if isempty(hPanelRawKymos) || not(isvalid(hPanelRawKymos))
            hTabRawKymos = tsDBM.create_tab('Raw Kymographs');
            hPanelRawKymos = uipanel('Parent', hTabRawKymos);
        end
        sessionGui.hPanelRawKymos = hPanelRawKymos;
        sessionGui.hTabRawKymos = hTabRawKymos;
        sessionGui.save_updates(sessionGui);
        
        tsDBM.select_tab(hTabRawKymos);

        import OldDBM.Kymo.UI.display_raw_kymos;
        display_raw_kymos(dbmODW, hPanelRawKymos);
    end

    function [] = on_display_aligned_kymos(dbmODW, tsDBM)
        sessionGui = get_session_object(tsDBM);
        
        import OldDBM.Kymo.DataBridge.create_and_set_all_missing_aligned_kymos;
        create_and_set_all_missing_aligned_kymos(dbmODW);
        
        dbmODW.verify_thresholds();
        [alignedKymos, alignedKymosStretchFactors, shiftAlignedKymos, alignedKymoFileIdxs, alignedKymoFileMoleculeIdxs] = dbmODW.get_all_existing_aligned_kymos();
        
        
        [kymoSrcFilenames] = dbmODW.get_molecule_src_filenames(alignedKymoFileIdxs);
        numAxes = numel(alignedKymos);

        import OldDBM.General.UI.Helper.get_header_texts;
        headerTexts = get_header_texts(alignedKymoFileIdxs, alignedKymoFileMoleculeIdxs, kymoSrcFilenames);
        
        
        import Fancy.UI.FancyPositioning.FancyGrid.generate_axes_grid;
        import OldDBM.Kymo.UI.show_kymos;
        
        if not(all(cellfun(@isempty, shiftAlignedKymos)))
            if not(isfield(sessionGui, 'hPanelShiftAlignedKymos'))
                sessionGui.hPanelShiftAlignedKymos = [];
            end
            if not(isfield(sessionGui, 'hTabShiftAlignedKymos'))
                sessionGui.hTabShiftAlignedKymos = [];
            end
            hPanelShiftAlignedKymos = sessionGui.hPanelShiftAlignedKymos;
            hTabShiftAlignedKymos = sessionGui.hTabShiftAlignedKymos;

            if isempty(hPanelShiftAlignedKymos) || not(isvalid(hPanelShiftAlignedKymos))
                hTabShiftAlignedKymos = tsDBM.create_tab('Shift Aligned Kymographs');
                hPanelShiftAlignedKymos = uipanel('Parent', hTabShiftAlignedKymos);
            end
            sessionGui.hPanelShiftAlignedKymos = hPanelShiftAlignedKymos;
            sessionGui.hTabShiftAlignedKymos = hTabShiftAlignedKymos;
            
            hAxesShiftAlignedKymos = generate_axes_grid(hPanelShiftAlignedKymos, numAxes);
            show_kymos(shiftAlignedKymos, hAxesShiftAlignedKymos, headerTexts);
        end

        if not(all(cellfun(@isempty, alignedKymosStretchFactors)))
            if not(isfield(sessionGui, 'hPanelAlignedKymosStretchFactors'))
                sessionGui.hPanelAlignedKymosStretchFactors = [];
            end
            if not(isfield(sessionGui, 'hTabAlignedKymosStretchFactors'))
                sessionGui.hTabAlignedKymosStretchFactors = [];
            end
            hPanelAlignedKymosStretchFactors = sessionGui.hPanelAlignedKymosStretchFactors;
            hTabAlignedKymosStretchFactors = sessionGui.hTabAlignedKymosStretchFactors;

            if isempty(hPanelAlignedKymosStretchFactors) || not(isvalid(hPanelAlignedKymosStretchFactors))
                hTabAlignedKymosStretchFactors = tsDBM.create_tab('Alignment Stretch Factors');
                hPanelAlignedKymosStretchFactors = uipanel('Parent', hTabAlignedKymosStretchFactors);
            end
            sessionGui.hPanelAlignedKymosStretchFactors = hPanelAlignedKymosStretchFactors;
            sessionGui.hTabAlignedKymosStretchFactors = hTabAlignedKymosStretchFactors;
            
            hAxesAlignedKymosStretchFactors = generate_axes_grid(hPanelAlignedKymosStretchFactors, numAxes);
            import OldDBM.Kymo.UI.show_kymos_stretch_factors;
            show_kymos_stretch_factors(alignedKymosStretchFactors, hAxesAlignedKymosStretchFactors, headerTexts);
        end
        
        if not(all(cellfun(@isempty, alignedKymos)))
            if not(isfield(sessionGui, 'hPanelAlignedKymos'))
                sessionGui.hPanelAlignedKymos = [];
            end
            if not(isfield(sessionGui, 'hTabAlignedKymos'))
                sessionGui.hTabAlignedKymos = [];
            end
            hPanelAlignedKymos = sessionGui.hPanelAlignedKymos;
            hTabAlignedKymos = sessionGui.hTabAlignedKymos;

            if isempty(hPanelAlignedKymos) || not(isvalid(hPanelAlignedKymos))
                hTabAlignedKymos = tsDBM.create_tab('Aligned Kymographs');
                hPanelAlignedKymos = uipanel('Parent', hTabAlignedKymos);
            end
            sessionGui.hPanelAlignedKymos = hPanelAlignedKymos;
            sessionGui.hTabAlignedKymos = hTabAlignedKymos;
            
            hAxesAlignedKymos = generate_axes_grid(hPanelAlignedKymos, numAxes);
            show_kymos(alignedKymos, hAxesAlignedKymos, headerTexts);
            tsDBM.select_tab(hTabAlignedKymos);
        end
        
        sessionGui.save_updates(sessionGui);
    end

    function [] = on_plot_kymo_time_averages(dbmODW, tsDBM)
        sessionGui = get_session_object(tsDBM);
        
        if not(isfield(sessionGui, 'hPanelAlignedKymoTimeTraces'))
            sessionGui.hPanelAlignedKymoTimeTraces = [];
        end
        if not(isfield(sessionGui, 'hTabAlignedKymoTimeTraces'))
            sessionGui.hTabAlignedKymoTimeTraces = [];
        end
        hPanelAlignedKymoTimeTraces = sessionGui.hPanelAlignedKymoTimeTraces;
        hTabAlignedKymoTimeTraces = sessionGui.hTabAlignedKymoTimeTraces;
        
        
        if isempty(hPanelAlignedKymoTimeTraces) || not(isvalid(hPanelAlignedKymoTimeTraces))
            hTabAlignedKymoTimeTraces = tsDBM.create_tab('Aligned Kymograph Time Traces');
            hPanelAlignedKymoTimeTraces = uipanel('Parent', hTabAlignedKymoTimeTraces);
        end
        sessionGui.hPanelAlignedKymoTimeTraces = hPanelAlignedKymoTimeTraces;
        sessionGui.hTabAlignedKymoTimeTraces = hTabAlignedKymoTimeTraces;
        
        sessionGui.save_updates(sessionGui);
        tsDBM.select_tab(hTabAlignedKymoTimeTraces);

        import OldDBM.Kymo.UI.plot_kymo_time_averages;
        plot_kymo_time_averages(dbmODW, hPanelAlignedKymoTimeTraces);
    end

    function [] = on_load_sess_data(dbmODW, dbmOSW, tsDBM)
        defaultSessionDirpath = dbmOSW.get_default_import_dirpath('session');

        import OldDBM.General.Import.try_prompt_single_session_filepath;
        sessionFilepath = try_prompt_single_session_filepath(defaultSessionDirpath);

        if isempty(sessionFilepath)
            return;
        end

        import OldDBM.General.Import.try_loading_from_session_file;
        dbmODW2 = try_loading_from_session_file(sessionFilepath);

        dbmODW.update_data(dbmODW2);

        import OldDBM.General.SettingsWrapper;
        dbmOSW2 = SettingsWrapper.import_dbm_settings_from_session_path(sessionFilepath);
        dbmOSW.update_settings(dbmOSW2);

        on_update_home_screen(dbmODW, tsDBM);
    end

    function [] = on_load_movies(dbmODW, dbmOSW, tsDBM)
        % this is in DBM.ini
        % averagingWindowWidth = dbmODW.get_averaging_window_width();

            switch dbmOSW.DBMSettingsstruct.dbmtool
                case 'old'

                     import OldDBM.General.Import.import_movies;
                    [fileCells, fileMoleculeCells, pixelsWidths_bps] = import_movies([],dbmOSW);     
                case 'corr'
                    % maybe make these into "cases"
                    import DBM4.import_movies;
                    %         import OldDBM.General.Import.import_movies;
                    [fileCells, fileMoleculeCells, pixelsWidths_bps] = DBM4.import_movies( dbmOSW.DBMSettingsstruct);     
                otherwise
                    % default to something..
            end
%         
%         import DBM4.import_movies;
%         %         import OldDBM.General.Import.import_movies;
%         [fileCells, fileMoleculeCells, pixelsWidths_bps] = DBM4.import_movies(sets);     
%         %      
%         import OldDBM.General.Import.import_movies;
%         [fileCells, fileMoleculeCells, pixelsWidths_bps] = import_movies(tsDBM,dbmOSW);

        dbmODW.DBMMainstruct.fileCell = fileCells;
        dbmODW.DBMMainstruct.fileMoleculeCell = fileMoleculeCells;

        numFiles = length(fileCells);
        fileIdxs = (1:numFiles)';
        dbmODW.set_molecule_src_pixel_widths_in_bps(fileIdxs, pixelsWidths_bps);
        on_update_home_screen(dbmODW, tsDBM);
    end

    function [] = on_load_raw_kymos(dbmODW, dbmOSW, tsDBM)
        defaultRawKymoDirpath = dbmOSW.get_default_import_dirpath('raw_kymo');

        import OldDBM.General.Import.import_raw_kymos;
        [rawKymos, rawKymoFilepaths] = import_raw_kymos(defaultRawKymoDirpath);

        
        numFiles = numel(rawKymos);
        pixelsWidths_bps = zeros(numFiles,1) - 1;

%         import OldDBM.General.Import.prompt_files_bps_per_pixel_wrapper;
%         [pixelsWidths_bps] = prompt_files_bps_per_pixel_wrapper(rawKymoFilepaths, tsDBM);
        
        import OldDBM.General.Import.set_raw_kymo_data;
        set_raw_kymo_data(dbmODW, rawKymos, rawKymoFilepaths, pixelsWidths_bps);
        
        on_update_home_screen(dbmODW, tsDBM);
    end

    function [] = on_calc_molecule_lengths_and_intensity(dbmODW, tsDBM,dbmOSW)

        import OldDBM.Kymo.UI.prompt_kymo_analysis_method;
        [kymoAnalysisMethod, shouldSaveTF] = prompt_kymo_analysis_method();
        
        skipEdgeDetection = false;
        skipDoubleTanhAdjustmentTF = true;
        switch kymoAnalysisMethod
            case 'kymo_edge'
                skipEdgeDetection = true;
            case 'basic_otsu_edge_detection'
                skipDoubleTanhAdjustmentTF = true;
            case 'double_tanh_edge_detection'
                skipDoubleTanhAdjustmentTF = false;
            otherwise
                return;
        end
%         import OldDBM.Kymo.UI.run_calc_plot_save_kymo_analysis;
        import DBM4.run_calc_plot_save_kymo_analysis;
        run_calc_plot_save_kymo_analysis(tsDBM, dbmODW, skipDoubleTanhAdjustmentTF, shouldSaveTF,dbmOSW.DBMSettingsstruct,skipEdgeDetection)
        
    end

    function [] = on_plot_molecule_lengths_hist(dbmODW, tsDBM)
        [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();
        moleculeLengths_pixels = dbmODW.get_molecule_lengths(fileIdxs, fileMoleculeIdxs);
        moleculeLengths_pixels = moleculeLengths_pixels(not(isnan(moleculeLengths_pixels)));
        if isempty(moleculeLengths_pixels)
            disp('There were no molecule lengths to plot');
            return;
        end

        import OldDBM.General.UI.add_molecule_lengths_hist_tab;
        hTabMLH = add_molecule_lengths_hist_tab(tsDBM, moleculeLengths_pixels);
        tsDBM.select_tab(hTabMLH);
    end
    
    function [] = on_plot_infoscore_hist(dbmODW, tsDBM)
        [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();
        infoScores = dbmODW.get_info_scores(fileIdxs, fileMoleculeIdxs);
        infoScores = infoScores(not(isnan(infoScores)));
        if isempty(infoScores)
            disp('There were no information scores to plot');
            return;
        end

        import OldDBM.General.UI.add_infoscore_hist_tab;
        hTabISD = add_infoscore_hist_tab(tsDBM, infoScores);
        tsDBM.select_tab(hTabISD);
    end

end
