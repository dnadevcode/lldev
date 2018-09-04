function [meltmapBarcodeFilepath] = prompt_meltmap_barcode_output_filepath(defaultMeltmapBarcodeFilepath)
    %%% Print the results to a file.
    % Print the header line.
    if nargin < 1
        [meltmapBarcodeFilename, meltmapBarcodeDirpath] = uiputfile('*.txt', 'Save Meltmap Barcode');
    else
        [meltmapBarcodeFilename, meltmapBarcodeDirpath] = uiputfile('*.txt', 'Save Meltmap Barcode', defaultMeltmapBarcodeFilepath);
    end
    meltmapBarcodeFilepath = 0;
    if isequal(meltmapBarcodeDirpath, 0)
        return;
    end
    meltmapBarcodeFilepath = fullfile(meltmapBarcodeDirpath, meltmapBarcodeFilename);
end