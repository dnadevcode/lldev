function [dbmStruct] = load_all_session_data(dbmStruct)
% %     % DBM old - add enough fields to be runnable via dna_barcode_matchmaker

    dbmStruct.fileCells = dbmStruct.fileCell;
    dbmStruct.fileCell = [];
    dbmStruct.fileMoleculeCells = dbmStruct.fileMoleculeCell;
    dbmStruct.fileMoleculeCell = [];
    dbmStruct.kymoCells = [];% create kymocells too;
                 % save kymos into single structure
    kymoCells = [];
    kymoCells.rawKymos = [];
    kymoCells.rawKymosDots = [];
    
    kymoCells.rawBitmask = [];
    kymoCells.kymosMoleculeLeftEdgeIdxs = [];
    kymoCells.kymosMoleculeRightEdgeIdxs = [];
    
    kymoCells.rawKymoFileIdxs = [];
    kymoCells.rawKymoFileMoleculeIdxs = [];
    kymoCells.rawKymoName = [];
    kymoCells.rawBitmaskName = [];
    kymoCells.enhanced = [];
    kymoCells.enhancedName = [];
    kymoCells.threshval = []; % for threshval (Bg mean)
    kymoCells.threshstd = [];
    kymoCells.bgnorm = [];
    kymoCells.snrValues = [];
    
    for rawMovieIdx=1:length(dbmStruct.fileMoleculeCells)
        numRawKymos = length(dbmStruct.fileMoleculeCells{rawMovieIdx});
        for rawKymoNum = 1:numRawKymos
            [~, srcFilenameNoExt, ~] = fileparts(dbmStruct.fileCells{rawMovieIdx}.fileName);
            kymoCells.rawKymos{end+1} = dbmStruct.fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymograph;
    %             if channels > 1
    %                 kymoCells.rawKymosDots{end+1} = dbmStruct.fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymographDots;
    %             end
    % 
    %             kymoCells.rawBitmask{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.moleculeMasks;
    %             try
    %                 kymoCells.threshval{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.threshval;
    %                 kymoCells.threshstd{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.threshstd;
    %                 kymoCells.bgnorm{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.bgnorm;
    % 
    %                 kymoCells.snrValues{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.snrValues;
    %             end
    % 
    %             % enhanced
    %             sampIm = mat2gray( kymoCells.rawKymos{end});
    %             minInt = min(sampIm(:));
    %             medInt = median(sampIm(:));
    % %             maxInt = max(sampIm(:));
    %             try
    %                 J = imadjust(sampIm,[minInt 4*medInt]);
    %             catch
    %                 J =  imadjust(sampIm,[0.1 0.9]);
    %             end
    %             kymoCells.enhanced{end+1} = J;
    % 
    %             kymoCells.kymosMoleculeLeftEdgeIdxs{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymosMoleculeLeftEdgeIdxs;
    %             kymoCells.kymosMoleculeRightEdgeIdxs{end+1} = fileMoleculeCells{rawMovieIdx}{rawKymoNum}.kymosMoleculeRightEdgeIdxs;
    % 
            kymoCells.rawKymoFileIdxs(end+1) = rawMovieIdx;
            kymoCells.rawKymoFileMoleculeIdxs(end+1) = rawKymoNum;
            kymoCells.rawKymoName{end+1} = sprintf('%s_molecule_%d_kymograph.tif', srcFilenameNoExt, rawKymoNum);
            kymoCells.rawBitmaskName{end+1} =  sprintf('%s_molecule_%d_bitmask.tif', srcFilenameNoExt, rawKymoNum);
            kymoCells.enhancedName{end+1} =  sprintf('%s_molecule_%d_enhanced.tif', srcFilenameNoExt, rawKymoNum);
    % 
        end
    end
    dbmStruct.kymoCells = kymoCells;
end

