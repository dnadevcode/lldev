function [] = export_contig_assembly_tree_txt(...
        sValue, ...
        coverage, ...
        conOrder, ...
        startMat, ...
        branchIdxs, ...
        usedContigs, ...
        strContigsTooShortSeqs, ...
        pixelsCut, ...
        dataSampleName ...
        )
    %---Save stuff to txt---
    [outputTxtFilename, dirpath] = uiputfile('*.txt', 'Save As');
    if isequal(dirpath, 0)
        return;
    end
    outputTxtFilepath = fullfile(dirpath, outputTxtFilename);
    timestamp = datestr(clock(), 'yyyy-mm-dd HH:MM:SS');
    fid = fopen(outputTxtFilepath,'w');
    fprintf(fid, '#Data: %s\n', dataSampleName);
    fprintf(fid, '#Date: %s\n', timestamp);
    fprintf(fid, '#Pixels cut: %d\n', pixelsCut);
    fprintf(fid, '#Total number of contigs used: %d\n', length(usedContigs));
    fprintf(fid, '#Contigs with too short sequence: %s\n', strContigsTooShortSeqs);
    fprintf(fid, '#\n');

    for branchIdx = branchIdxs
        fprintf(fid, 'Branch: %d\n', branchIdx);
        fprintf(fid, 'S-value: %g\n', sValue(branchIdx));
        fprintf(fid, 'Coverage: %g\n', coverage(branchIdx));
        fprintf(fid, 'Contig\tStart position\n');
        for iText = 1:sum(conOrder(branchIdx,:) ~= 0)
            fprintf(fid, '%2.0f\t\t', conOrder(branchIdx,iText));
            fprintf(fid, '%3.0f\n', startMat(branchIdx,iText));
        end
        fprintf(fid, '%s\n', '');
    end
    fclose(fid);
end