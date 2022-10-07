function [] = show_home_screen(dbmODW, hPanelHomescreen)
    % SHOW_HOME_SCREEN - displays the home screen
    %
    % Inputs:
    %   dbmODW
    %   hPanelHomescreen
    %
    % Authors:
    %   Saair Quaderi (complete refactoring)
    %   Charleston Noble
    

    [fileIdxs, fileMoleculeIdxs] = dbmODW.get_molecule_idxs();
    moleculeStatuses = dbmODW.get_molecule_statuses(fileIdxs, fileMoleculeIdxs);
    passesFilters = moleculeStatuses.passesFilters;
    fileIdxs = fileIdxs(passesFilters);
    fileMoleculeIdxs = fileMoleculeIdxs(passesFilters);


    uniqueFileIdxs = unique(fileIdxs);
    numUniqueFiles = length(uniqueFileIdxs);

    numNewAxisHandles = numUniqueFiles;

    % todo: simplify axes and add save button
    import Fancy.UI.FancyPositioning.FancyGrid.generate_axes_grid;
    hNewAxes = generate_axes_grid(hPanelHomescreen, numNewAxisHandles);
%     hTabgroup = uitabgroup('Parent',hPanelHomescreen);
%     hResScores= uitab(hTabgroup);
%     hNewAxes =axes(hResScores);
    import OldDBM.General.UI.disp_rect_annotated_image;
    for uniqueFileNum = 1:numUniqueFiles
        fileIdx = uniqueFileIdxs(uniqueFileNum);
        hAxis = hNewAxes(uniqueFileNum);
        srcFilename = dbmODW.get_molecule_src_filename(fileIdx);
        movieFrameTimeAvg = dbmODW.get_molecule_src_movie_frame_time_avg(fileIdx);

        fileImgHeaderText = make_file_img_header_text(srcFilename, fileIdx);

        currMask = (fileIdxs == fileIdx);
        moleculeRectPositions = dbmODW.get_molecule_rect_positions(fileIdxs(currMask), fileMoleculeIdxs(currMask));
        validRectPosMask = cellfun(@(moleculeRectPosition) not(any(isnan(moleculeRectPosition))), moleculeRectPositions);
        moleculeRectPositions = moleculeRectPositions(validRectPosMask);

        disp_rect_annotated_image(hAxis, movieFrameTimeAvg, fileImgHeaderText, moleculeRectPositions);
    end

    function [headerText] = make_file_img_header_text(srcFilename, fileIdx)
        headerText = textscan(srcFilename, '%s');
        headerText = headerText{1}(end);
        headerText = strcat(headerText, ' (File #', num2str(fileIdx), ')');
    end

end