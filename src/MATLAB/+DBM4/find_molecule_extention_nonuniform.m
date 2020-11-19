function [] = find_molecule_extention_nonuniform(fold,foldOut)

    if nargin < 1
        % folder with images to classify
        fold = uigetdir(pwd, "Folder with tifs we want to find edges for");
    end


    if nargin < 2
        % folder with images to classify
        foldOut = uigetdir(pwd,"Output folder");
    end
    
        % run single example edge detection
    % where the folder with tif files is
    kymoDir = fold;
    example = dir(strcat(kymoDir,'*.tif'));

    examples = {example.name};

    % examples = {examples{1}};
    % examples =
    fileMoleculeCells = cell(1,length(examples));
    fileCells = cell(1,length(examples));
    % moleculeStructs = cell(1,length(examples));

    for i=1:length(examples)
        moleculeStructs = cell(1,1);

        kymo = imread(fullfile(kymoDir,examples{i}));

        moleculeStructs{1}.miniRotatedMovie = kymo;
        moleculeStructs{1}.kymograph = double(kymo);
        moleculeStructs{1}.passesFilters = 1;
        fileStruct = struct();
        fileStruct.fileName = examples{i};
        fileStruct.averagedImg = kymo;
        fileStruct.locs = [];
        fileStruct.regions = [];
        fileCells{i} = fileStruct;
        fileMoleculeCells{i} = moleculeStructs;

    end



    % first put kymo to DBM structure so that it can be accessed
    import OldDBM.General.DataWrapper;
    dbmODW = DataWrapper();    
    dbmODW.DBMMainstruct.fileCell = fileCells;
    dbmODW.DBMMainstruct.fileMoleculeCell = fileMoleculeCells;

    % % run analysis
    % import OldDBM.Kymo.UI.run_kymo_analysis;
    % kymoStatsTable = run_kymo_analysis(dbmODW, 1);
    % 
    % fileIdxs= 1:length(examples);
    % fileMoleculeIdxs =repmat(1,1,length(examples))';

    fold = foldOut;
    % output folder
    settings.dirs.stats =fold;
    settings.dirs.pngs = fold;
    mkdir(fold);
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    % 
    % import OldDBM.Kymo.Helper.get_raw_kymo_edge_plot_png_output_filepaths;
    % pngOutputFilepaths = get_raw_kymo_edge_plot_png_output_filepaths(dbmODW, fileIdxs, 1, settings.dirs.pngs,timestamp);
    % 
    % 
    % numKymos = length(fileIdxs);
    % kymosMoleculeLeftEdgeIdxs = cell(numKymos, 1);
    % kymosMoleculeRightEdgeIdxs = cell(numKymos, 1);
    % for kymoNum = 1:numKymos
    %     fileIdx = fileIdxs(kymoNum);
    %     fileMoleculeIdx = fileMoleculeIdxs(1);
    %     rowIdx = find((kymoStatsTable.fileIdx == fileIdx) & (kymoStatsTable.fileMoleculeIdx == fileMoleculeIdx), 1, 'first');
    % 
    %     if not(isempty(rowIdx))
    %         kymoMoleculeLeftEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeLeftEdgeIdxs'}{1};
    %         kymoMoleculeRightEdgeIdxs = kymoStatsTable{rowIdx, 'moleculeRightEdgeIdxs'}{1};
    %         kymosMoleculeLeftEdgeIdxs{kymoNum} = kymoMoleculeLeftEdgeIdxs;
    %         kymosMoleculeRightEdgeIdxs{kymoNum} = kymoMoleculeRightEdgeIdxs;
    %     end
    % end
    % 
    % rawKymos = dbmODW.get_raw_kymos(fileIdxs, fileMoleculeIdxs);
    % 
    %     
    % shouldSavePngTF = 2;
    % fprintf('Saving kymographs with edges as png files...\n');
    % if shouldSavePngTF ~= 2
    % % Save images of the axes
    %     import OldDBM.General.Export.export_axis_image_as_png;
    %     arrayfun(@(kymoIdx) export_axis_image_as_png(hAxesPlots(kymoIdx), pngOutputFilepaths{kymoIdx}), (1:numKymos)', 'UniformOutput', false);
    % else
    %     import DBM4.export_image_as_png;
    %     export_image_as_png(dbmODW, fileIdxs, fileMoleculeIdxs,kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs,pngOutputFilepaths);
    % end
    % fprintf('Finished saving png files.\n');
    % 
    %     
    %     

    % % plot results
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

    import DBM4.run_calc_plot_save_kymo_analysis;
    run_calc_plot_save_kymo_analysis(tsDBM, dbmODW, 1, 2,settings)
    delete(hFig);


end

