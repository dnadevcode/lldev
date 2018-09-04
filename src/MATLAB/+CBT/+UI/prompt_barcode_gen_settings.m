function barcodeGenSettings = prompt_barcode_gen_settings()

    promptsStruct.concNetropsin_molar = 'Netropsin conc. (molar):';
    promptsStruct.concYOYO1_molar = 'YOYO-1 conc. (molar):';
    promptsStruct.meanBpExt_nm = 'Mean basepair ext (nm):';
    promptsStruct.psfSigmaWidth_nm = 'PSF sigma width (nm):';
    promptsStruct.pixelWidth_nm = 'Camera pixel width (nm):';

    import CBT.get_default_barcode_gen_settings;
    defaultBarcodeGenSettings = get_default_barcode_gen_settings();

    fnStringify.concNetropsin_molar = @num2str;
    fnStringify.concYOYO1_molar = @num2str;
    fnStringify.meanBpExt_nm = @num2str;
    fnStringify.psfSigmaWidth_nm = @num2str;
    fnStringify.pixelWidth_nm = @num2str;

    fnDetringify.concNetropsin_molar = @str2double;
    fnDetringify.concYOYO1_molar = @str2double;
    fnDetringify.meanBpExt_nm = @str2double;
    fnDetringify.psfSigmaWidth_nm = @str2double;
    fnDetringify.pixelWidth_nm = @str2double;

    dlg_title = 'CA Barcode Gen Settings';
    num_lines = 1;
    fieldList = fields(promptsStruct);
    prompts = cellfun(...
        @(fieldname) promptsStruct.(fieldname), ...
        fieldList, ...
        'UniformOutput', false);
    defaultAnswerStrs = cellfun(...
            @(fieldname) feval(fnStringify.(fieldname), defaultBarcodeGenSettings.(fieldname)), ...
            fieldList, ...
            'UniformOutput', false);
    answerStrs = inputdlg(...
        prompts,...
        dlg_title, ...
        num_lines, ...
        defaultAnswerStrs ...
    );

    for fieldNum = 1:length(fieldList)
        fieldname = fieldList{fieldNum};
        barcodeGenSettings.(fieldname) = feval(fnDetringify.(fieldname), answerStrs{fieldNum});
    end
end