function [] = export_exps_vs_exps_numeric_mat_txt(sValMat, barcodeNames, dataDescriptionStr)
    % Saves the p-value matrix from ETE_all into a text file.

    [txtFilename, outputDirpath] = uiputfile('*.txt', 'Save As');
    txtFilepath = fullfile(outputDirpath, txtFilename);

    timestamp = datestr(clock(),'yyyy-mm-dd HH:MM:SS');
    numBarcodes = length(barcodeNames);

    fid = fopen(txtFilepath,'w');

    % Write header
    fprintf(fid,'#Date: %s\n', timestamp);
    fprintf(fid,'#Number of barcodes: %d\n', numBarcodes);
    fprintf(fid,'#Data type: %s\n', dataDescriptionStr);
    fprintf(fid,'#\n');

    % Write first row (containing barcode names)
    tabWidth = 4;
    maxNameWidth = 23;
    fprintf(fid,['#', repmat('\t', [1, ceil(maxNameWidth/tabWidth)])]);
    for barcodeNum = 1:numBarcodes
        barcodePrintName = barcodeNames{barcodeNum}(1:min(end, maxNameWidth));
        barcodePrintNameLen = length(barcodePrintName);
        numTabsAfterName = ceil(maxNameWidth/tabWidth) - floor(barcodePrintNameLen/tabWidth);
        formatString = ['%s', repmat('\t', [1, numTabsAfterName])];
        fprintf(fid, formatString, barcodePrintName);
    end
    fprintf(fid,'\n');

    % Fill in rest of matrix
    for barcodeIdxA = 1:numBarcodes
        barcodePrintName = barcodeNames{barcodeIdxA}(1:min(end, maxNameWidth));
        barcodePrintNameLen = length(barcodePrintName);
        numTabsAfterName = ceil(maxNameWidth/tabWidth) - floor(barcodePrintNameLen/tabWidth);
        formatString = ['%s', repmat('\t', [1, numTabsAfterName])];
        fprintf(fid,formatString,barcodePrintName);
        for barcodeIdxB = 1:length(barcodeNames)
            fprintf(fid, '%4.4e\t\t\t\t', sValMat(barcodeIdxA,barcodeIdxB));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end