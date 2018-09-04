function [barcodeGenSettings] = get_zero_model_seq2barcode_gen_settings()
    import CBT.get_default_barcode_gen_settings;
    defaultBarcodeGenSettings = get_default_barcode_gen_settings();
    barcodeGenSettings = defaultBarcodeGenSettings;


    % Input for theory barcode parameters
    prompts = {'Mean basepair ext (nm):'};
    defaultVals = {num2str(barcodeGenSettings.meanBpExt_nm)};
    dlg_title = 'Input for theory barcodes';
    num_lines = 1;
    answers = inputdlg(prompts,dlg_title,num_lines,defaultVals);

    barcodeGenSettings.meanBpExt_nm = str2double(answers{1});
end