function [] = run_calc_plot_save_kymo_analysis(tsDBM, dbmODW, skipDoubleTanhAdjustmentTF, shouldSavePngTF)
    import OldDBM.Kymo.UI.run_kymo_analysis;
    kymoStatsTable = run_kymo_analysis(dbmODW, skipDoubleTanhAdjustmentTF);

    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    defaultStatsOutputDirpath =  appDirpath;
    
    defaultStatsOutputFilepath = fullfile(defaultStatsOutputDirpath, 'stats.mat');
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
    
    hTabEdgeDetection = tsDBM.create_tab('Raw Kymo Edge Detection');
    tsDBM.select_tab(hTabEdgeDetection);
    hPanel = uipanel('Parent', hTabEdgeDetection);
    import OldDBM.Kymo.UI.plot_detected_raw_kymo_edges;
    hAxesPlots = plot_detected_raw_kymo_edges(dbmODW, fileIdxs, fileMoleculeIdxs, hPanel, kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs);

    if not(shouldSavePngTF)
        return;
    end
    import OldDBM.Kymo.Helper.get_raw_kymo_edge_plot_png_output_filepaths;
    pngOutputFilepaths = get_raw_kymo_edge_plot_png_output_filepaths(dbmODW, fileIdxs, fileMoleculeIdxs);

    % Save images of the axes
    import OldDBM.General.Export.export_axis_image_as_png;
    arrayfun(@(kymoIdx) export_axis_image_as_png(hAxesPlots(kymoIdx), pngOutputFilepaths{kymoIdx}), (1:numKymos)', 'UniformOutput', false);
end