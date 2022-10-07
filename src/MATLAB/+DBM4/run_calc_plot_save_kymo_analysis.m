function [] = run_calc_plot_save_kymo_analysis(tsDBM, dbmODW, skipDoubleTanhAdjustmentTF, shouldSavePngTF,settings,skipEdgeDetection)
    %
    %
    %   Args:
    %       tsDBM, dbmODW, skipDoubleTanhAdjustmentTF, shouldSavePngTF
    %
    %   Returns:
    %
    %
    
    
    %% could have possibility to load from session file directly here?
%     import OldDBM.General.DataWrapper;
%     dbmODW = DataWrapper();
%     dbmODW.DBMMainstruct = DBMMainstruct;
%      dbmODW.DBMMainstruct.fileCell
%     skipDoubleTanhAdjustmentTF = 1;
%     shouldSavePngTF = 2;
%     
%     for i=2:10
%         dbmODW.DBMMainstruct.fileMoleculeCell{i} = dbmODW.DBMMainstruct.fileMoleculeCell{1};
%         dbmODW.DBMMainstruct.fileCell{i} = dbmODW.DBMMainstruct.fileCell{1};
%          dbmODW.DBMMainstruct.fileCell{i}.fileName = strcat(dbmODW.DBMMainstruct.fileCell{1}.fileName,num2str(i));
%     end
%     dbmODW.DBMMainstruct.fileMoleculeCell = fileMoleculeCells;

        
    
    % generate
    import OldDBM.Kymo.UI.run_kymo_analysis;
    kymoStatsTable = run_kymo_analysis(dbmODW, skipDoubleTanhAdjustmentTF,skipEdgeDetection);

    defaultStatsOutputDirpath =   settings.dirs.stats;
    
    % add timestamp
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    filename = sprintf('stats_%s.mat', timestamp);

    defaultStatsOutputFilepath = fullfile(defaultStatsOutputDirpath, filename);
    [statsOutputMatFilename, statsOutputMatDirpath, ~] = uiputfile('*.mat', 'Save Molecule Stats As', defaultStatsOutputFilepath);
    
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

    [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();

    [moleculeStatuses] = dbmODW.get_molecule_statuses(fileIdxs, fileMoleculeIdxs);
    selectionMask = moleculeStatuses.hasRawKymo;
    % selectionMask = selectionMask & moleculeStatuses.passesFilters;

    fileIdxs = fileIdxs(selectionMask);
    fileMoleculeIdxs = fileMoleculeIdxs(selectionMask);

    numKymos = length(fileMoleculeIdxs);
    kymosMoleculeLeftEdgeIdxs = cell(numKymos, 1);
    kymosMoleculeRightEdgeIdxs = cell(numKymos, 1);
    for kymoNum = 1:numKymos
        fileIdx = fileIdxs(kymoNum);
        fileMoleculeIdx = fileMoleculeIdxs(kymoNum);
        rowIdx = find((kymoStatsTable.fileIdx == fileIdx) & (kymoStatsTable.fileMoleculeIdx == fileMoleculeIdx), 1, 'first');
        
        if not(isempty(rowIdx))
            kymoMoleculeLeftEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeLeftEdgeIdxs'}{1};
            kymoMoleculeRightEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeRightEdgeIdxs'}{1};
            kymosMoleculeLeftEdgeIdxs{kymoNum} = kymoMoleculeLeftEdgeIdxs;
            kymosMoleculeRightEdgeIdxs{kymoNum} = kymoMoleculeRightEdgeIdxs;
        end
    end

    % [kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs] = dbmODW.get_raw_kymos_molecules_edge_idxs(fileIdxs, fileMoleculeIdxs);
    
    % should not display this if there are too many molecules..!
    
    if shouldSavePngTF ~= 2
        hTabEdgeDetection = tsDBM.create_tab('Raw Kymo Edge Detection');
        tsDBM.select_tab(hTabEdgeDetection);
        hPanel = uipanel('Parent', hTabEdgeDetection);
    % hPanel = figure('visible','off');
        import OldDBM.Kymo.UI.plot_detected_raw_kymo_edges;
        hAxesPlots = plot_detected_raw_kymo_edges(dbmODW, fileIdxs, fileMoleculeIdxs, hPanel, kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs);
    end
    
    if not(shouldSavePngTF)
        return;
    end
    
    
    import OldDBM.Kymo.Helper.get_raw_kymo_edge_plot_png_output_filepaths;
    pngOutputFilepaths = get_raw_kymo_edge_plot_png_output_filepaths(dbmODW, fileIdxs, fileMoleculeIdxs, settings.dirs.pngs,timestamp);

    fprintf('Saving kymographs with edges as png files...\n');
    if shouldSavePngTF ~= 2
    % Save images of the axes
        import OldDBM.General.Export.export_axis_image_as_png;
        arrayfun(@(kymoIdx) export_axis_image_as_png(hAxesPlots(kymoIdx), pngOutputFilepaths{kymoIdx}), (1:numKymos)', 'UniformOutput', false);
    else
        import DBM4.export_image_as_png;
        export_image_as_png(dbmODW, fileIdxs, fileMoleculeIdxs,kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs,pngOutputFilepaths);
    end
    fprintf('Finished saving png files.\n');

end