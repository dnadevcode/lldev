function [] = export_contig_placement_txt(placedContigBarcodes, rescaledConcensusBarcode, consensusBarcodeName)
    outputMatrix = NaN(length(rescaledConcensusBarcode), length(placedContigBarcodes) + 1);
    outputMatrix(:,1) = rescaledConcensusBarcode(:, 1);
    for contigNum = 1:length(placedContigBarcodes)
        outputMatrix(:,1+contigNum) = placedContigBarcodes{contigNum};
    end

    dialogTitleStr = sprintf('Save %s As', consensusBarcodeName);

    [outputTxtFilename, dirpath] = uiputfile('*.txt', dialogTitleStr);
    if isequal(dirpath, 0)
        return;
    end
    outputTxtFilepath = fullfile(dirpath, outputTxtFilename);
    dlmwrite(outputTxtFilepath, outputMatrix, 'delimiter','\t');
end