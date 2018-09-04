function [] = export_mean_sval_mat_mean_txt(sValMat, barcodeNames)
    % Saves the p-value matrix from ETE after applying a geometric
    % mean to it.

    [txtFilename, outputDirpath] = uiputfile('*.txt', 'Save As');
    txtFilepath = fullfile(outputDirpath, txtFilename);

    sValMean = sqrt(sValMat.*sValMat');

    timestamp = datestr(clock(),'yyyy-mm-dd HH:MM:SS');
    numBarcodes = length(barcodeNames);

    fid = fopen(txtFilepath,'w');

    % Write header
    fprintf(fid,'#Date: %s\n', timestamp);
    fprintf(fid,'#Number of barcodes: %d\n', numBarcodes);
    fprintf(fid,'#Data type: P-value\n');
    fprintf(fid,'#\n');

    % Write first row (containing barcode names)
    fprintf(fid,'%s\t\t\t\t\t\t','#');
    for barcodeIdxA = 1:numBarcodes
        barcodePrintName = barcodeNames{barcodeIdxA}(1:min(end, maxNameWidth));
        barcodePrintNameLen = length(barcodePrintName);
        numTabsAfterName = ceil(maxNameWidth/tabWidth) - floor(barcodePrintNameLen/tabWidth);
        formatString = ['%s', repmat('\t', [1, numTabsAfterName])];
        fprintf(fid,formatString,barcodePrintName);
    end
    fprintf(fid,'\n');

    % Fill in rest of matrix
    for barcodeIdxA = 1:numBarcodes
        barcodePrintName = barcodeNames{barcodeIdxA}(1:min(end, maxNameWidth));
        barcodePrintNameLen = length(barcodePrintName);
        numTabsAfterName = ceil(maxNameWidth/tabWidth) - floor(barcodePrintNameLen/tabWidth);
        formatString = ['%s', repmat('\t', [1, numTabsAfterName])];
        fprintf(fid,formatString,barcodePrintName);
        for barcodeIdxB = 1:(barcodeIdxA - 1)
            fprintf(fid, '%4.4f\t\t\t\t', sValMean(barcodeIdxA, barcodeIdxB));
        end
        fprintf(fid, '\n');
    end
    fclose(fid);
end