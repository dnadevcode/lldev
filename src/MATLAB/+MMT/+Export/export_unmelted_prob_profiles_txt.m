function [] = export_unmelted_prob_profiles_txt(meltmapBarcodes_bpRes_prePSF, temperature_Celsius, saltConc_molar, meltmapBarcodeFilepath)
    if (nargin < 4) || isempty(meltmapBarcodeFilepath)
        import AppMgr.AppResourceMgr;
        appRsrcMgr = AppResourceMgr.get_instance();
        appDirpath = appRsrcMgr.get_app_dirpath();
        defaultMeltmapBarcodeDirpath = appDirpath;
        defaultMeltmapBarcodeFilename = sprintf('unmelted_prob_%gM_%gC.txt', saltConc_molar, temperature_Celsius);
        defaultMeltmapBarcodeFilepath = fullfile(defaultMeltmapBarcodeDirpath, defaultMeltmapBarcodeFilename);
        import MMT.Import.prompt_meltmap_barcode_output_filepath;
        meltmapBarcodeFilepath = prompt_meltmap_barcode_output_filepath(defaultMeltmapBarcodeFilepath);
    end
    if isequal(meltmapBarcodeFilepath, 0)
        return;
    end

    fidMeltmapProtobarcode = fopen(meltmapBarcodeFilepath, 'w');
    barcodeLen = length(meltmapBarcodes_bpRes_prePSF);
    for barcodePosIdx = 1:barcodeLen
        fprintf(fidMeltmapProtobarcode, '%f\n', meltmapBarcodes_bpRes_prePSF(barcodePosIdx));
    end
    fclose(fidMeltmapProtobarcode);
end