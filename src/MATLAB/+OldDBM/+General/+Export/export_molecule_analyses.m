function [] = export_molecule_analyses(dbmODW, dbmOSW)
    % EXPORT_MOLECULE_ANALYSES - Exports analysis data regarding individual molecules
    %
    % Authors:
    %   Charleston Noble

    %%% Print the results to a file.
    % Print the header line.

    defaultAnalysisOutputDirpath = dbmOSW.get_default_export_dirpath('molecule_analysis');
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    defaultAnalysisOutputFilename = sprintf('analysis_%s.txt', timestamp);
    defaultAnalysisOutputFilepath = fullfile(defaultAnalysisOutputDirpath, defaultAnalysisOutputFilename);
    [analysisOutputFilename, analysisOutputDirpath, ~] = uiputfile('*.txt', 'Save analysis', defaultAnalysisOutputFilepath);
    analysisOutputFilepath = fullfile(analysisOutputDirpath, analysisOutputFilename);
    if isequal(analysisOutputDirpath, 0)
        return 
    end

    [~, ~, alignedKymoFileIdxs, alignedKymoFileMoleculeIdxs] = dbmODW.get_all_existing_aligned_kymos();
    numMolecules = length(alignedKymoFileMoleculeIdxs);

    if numMolecules == 0
        disp('No aligned kymographs were found. Kymographs must be aligned before molecule information can be exported.');
    end


    fid = fopen(analysisOutputFilepath, 'w');
    fprintf(fid, '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s', ...
        '"FileName"', 'MoleculeNumber', 'Length', 'STD', 'Information', 'INT', 'stdINT', 'bgINT');

    fprintf(fid, '\n');

    [srcFilenames] = dbmODW.get_molecule_src_filenames(alignedKymoFileIdxs);

    % Print the information lines for each of the images.
    for moleculeNum = 1:numMolecules
        alignedKymoFileIdx = alignedKymoFileIdxs(moleculeNum);
        alignedKymoFileMoleculeIdx = alignedKymoFileMoleculeIdxs(moleculeNum);
        srcFilename = srcFilenames{moleculeNum};

        [moleculeStruct] = dbmODW.get_molecule_struct(alignedKymoFileIdx, alignedKymoFileMoleculeIdx);

        lengthEst_px = dbmODW.get_molecule_length(alignedKymoFileIdx, alignedKymoFileMoleculeIdx);
        if isnan(lengthEst_px)
            warning('Molecule length hasn''t been calculated')
        end

        lengthDevEst = [];
        if isfield(moleculeStruct, 'lengthSTD')
            lengthDevEst = moleculeStruct.lengthSTD;
        end

        meanKymoRowFgIntensity = moleculeStruct.INT;
        meanOfMeanKymoRowFgIntensity = mean(meanKymoRowFgIntensity);
        stdOfMeanKymoRowFgIntensity = std(meanKymoRowFgIntensity);

        meanKymoBgIntensity = moleculeStruct.BGint;


        alignedKymoInfoScore = dbmODW.get_info_score(alignedKymoFileIdx, alignedKymoFileMoleculeIdx);
        if isnan(alignedKymoInfoScore)
            alignedKymoInfoScore = [];
        end
        fprintf(fid, ...
            '"%s"\t%d\t%6.2f\t%7.3f\t%6.1f\t%1.3f\t%1.0f\t%1.3f\t%1.0f\n', ...
            srcFilename, ...
            alignedKymoFileMoleculeIdx, ...
            lengthEst_px, ...
            lengthDevEst, ...
            alignedKymoInfoScore, ...
            meanOfMeanKymoRowFgIntensity, ...
            stdOfMeanKymoRowFgIntensity, ...
            meanKymoBgIntensity...
            );
    end

    % Close the file.
    fclose(fid);
end
