function [] = export_raw_kymos(dbmODW, defaultOutputDirpath)
    [rawKymos, rawKymoFileIdxs, rawKymoFileMoleculeIdxs] = dbmODW.get_all_existing_raw_kymos();
    if isempty(rawKymos)
        fprintf('No raw kymographs were present to be exported\n');
        return;
    end

    outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Raw Kymo Files');

    if isequal(outputDirpath, 0)
        return;
    end

    [srcFilenames] = dbmODW.get_molecule_src_filenames(rawKymoFileIdxs);

    numRawKymos = length(rawKymos);
    outputKymoFilepaths = cell(numRawKymos, 1);
%     outputKymoFilepaths2 = cell(numRawKymos, 1);

    for rawKymoNum = 1:numRawKymos
        [~, srcFilenameNoExt, ~] = fileparts(srcFilenames{rawKymoNum});
        fileMoleculeIdx = rawKymoFileMoleculeIdxs(rawKymoNum);
        outputKymoFilename = sprintf('%s_molecule_%d_kymograph.tif', srcFilenameNoExt, fileMoleculeIdx);
        outputKymoFilepath = fullfile(outputDirpath, outputKymoFilename);
        outputKymoFilepaths{rawKymoNum} = outputKymoFilepath;
%         try
%         outputKymoFilename2 = sprintf('%s_molecule_%d_bitmask.tif', srcFilenameNoExt, fileMoleculeIdx);
%         outputKymoFilepath2 = fullfile(outputDirpath, outputKymoFilename2);
%             imwrite(uint16(fileMoleculeCells{rawMovieIdx}{rawKymoNum}.moleculeMasks), outputKymoFilepath, 'tif');
%         end
    end
    
    cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(rawKymo, outputKymoFilepath, 'tif'),...
        rawKymos, outputKymoFilepaths);
    
    
end