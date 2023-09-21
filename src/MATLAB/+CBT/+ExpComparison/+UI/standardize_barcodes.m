function [stretchedBarcodes, stretchedKbpsPerPixel] = standardize_barcodes(barcodes, barcodeNames, forceStretchToSameBpsPerPixel)
    if nargin < 3
        forceStretchToSameBpsPerPixel = false;
    end


    % Choose which kind of length input for the ZM barcodes
    optStretchToSameLen = 'Stretch to same length';
    optStandardizeByBpExtLens = 'Prompt for basepair ext lens (nm/bp)';
    optInputBarcodeBpLens = 'Prompt for barcode lens (kbps)';
    if forceStretchToSameBpsPerPixel
        lenNormalizationOption = questdlg(...
            'Select barcode length normalization method', ...
            'Normalization Method Selection', ...
            optStandardizeByBpExtLens, ...
            optInputBarcodeBpLens, ...
            optInputBarcodeBpLens);
    else
        lenNormalizationOption = questdlg(...
            'Select barcode length normalization method', ...
            'Normalization Method Selection', ...
            optStretchToSameLen, ...
            optStandardizeByBpExtLens, ...
            optInputBarcodeBpLens, ...
            optStandardizeByBpExtLens);
    end

    optImportParamsFromFile = 'File';
    optManuallyPromptForParams = 'Manually';
    promptTypeOption = questdlg(...
        'Input through a file or manually?', ...
        'Input Mathod Selection', ...
        optImportParamsFromFile, ...
        optManuallyPromptForParams, ...
        optImportParamsFromFile);
    shouldImportFromFile = strcmp(promptTypeOption, optImportParamsFromFile);


    numBarcodes = length(barcodes);
    barcodeLens_pixels = cellfun(@length, barcodes(:));

    % Length input and stretching
    stretchToSameLength = strcmp(lenNormalizationOption, optStretchToSameLen);
    stretchToSameBpsPerPixelBasedOnMeanBpExts = strcmp(lenNormalizationOption, optStandardizeByBpExtLens);
    stretchToSameBpsPerPixelBasedOnLensInKbps = strcmp(lenNormalizationOption, optInputBarcodeBpLens);


    stretchToSameBpsPerPixel = stretchToSameBpsPerPixelBasedOnMeanBpExts || stretchToSameBpsPerPixelBasedOnLensInKbps;

    import CBT.get_default_barcode_gen_settings;
    defaultBarcodeGenSettings = get_default_barcode_gen_settings();
    barcodeGenSettings = defaultBarcodeGenSettings;

    vectDefaultPixelWidths_nm = repmat(barcodeGenSettings.pixelWidth_nm, [numBarcodes, 1]);
    vectDefaultMeanBpExts_nm = repmat(barcodeGenSettings.meanBpExt_nm, [numBarcodes, 1]);

    if stretchToSameLength
        repmat(barcodeGenSettings.meanBpExt_nm, [numBarcodes, 1]);
        % User input
        if shouldImportFromFile
            import CBT.ExpComparison.Core.BarcodeLenNormalization.Helpers.Import.import_numeric_vector_from_textfile;
            vectBarcodeLens_kbps = import_numeric_vector_from_textfile('Select Text with Barcode Lens (Kbps)');
        else
            % Calculate kbp/pixel values
            vectDefaultKbpsPerPixel = vectDefaultPixelWidths_nm ./ (1000 * vectDefaultMeanBpExts_nm);
            vectDefaultKbpsPerPixel = round(1000 * vectDefaultKbpsPerPixel)/1000;
            vectDefaultBarcodeLens_kbps = barcodeLens_pixels .* vectDefaultKbpsPerPixel;
            defaultBarcodeLens_kbps_strs = arrayfun(@num2str, vectDefaultBarcodeLens_kbps, 'UniformOutput', false);

            promptsBarcodeLens_kbps = barcodeNames;
            answers_vectBarcodeLens_kbps = inputdlg(promptsBarcodeLens_kbps, 'Barcode lengths (kbps)', 1, defaultBarcodeLens_kbps_strs);
            vectBarcodeLens_kbps = str2double(answers_vectBarcodeLens_kbps);
        end
        vectBarcodeLens_kbps = vectBarcodeLens_kbps(:);

        if length(vectBarcodeLens_kbps) ~= numBarcodes
            fprintf('Aborting because lengths were not provided for all barcodes\n');
            stretchedBarcodes = {};
            stretchedKbpsPerPixel = [];
            return;
        end
        % Calculate kbp/pixel values
        vectKbpsPerPixel = vectBarcodeLens_kbps ./ barcodeLens_pixels;


        % Stretch all barcodes to the same kbp/pixel
        [~, sparsestKbpsPerPixelIdx] = min(vectKbpsPerPixel);
        sparsestBarcodeLen_pixels = barcodeLens_pixels(sparsestKbpsPerPixelIdx);


        stretchedBarcodeLens_pixels = repmat(sparsestBarcodeLen_pixels, [numBarcodes, 1]);
        vectStretchFactors = barcodeLens_pixels ./ stretchedBarcodeLens_pixels;
        stretchedKbpsPerPixel = vectKbpsPerPixel ./ vectStretchFactors;
        stretchedKbpsPerPixel = round(1000 * stretchedKbpsPerPixel)/1000;
    elseif stretchToSameBpsPerPixel

        if stretchToSameBpsPerPixelBasedOnMeanBpExts
            if shouldImportFromFile
                import CBT.ExpComparison.Core.BarcodeLenNormalization.Helpers.Import.import_numeric_vector_from_textfile;
                vectMeanBpExts_nm = import_numeric_vector_from_textfile('Select Text with Mean bp extensions (nm)');
                vectMeanBpExts_nm = cellfun(@str2double, vectMeanBpExts_nm);
            else
                promptBpsPerMicrometer = barcodeNames(:);
                defaultMeanBpExts_nm_strs = arrayfun(@num2str, vectDefaultMeanBpExts_nm, 'UniformOutput', false);

                answers_vectMeanBpExts_nm = inputdlg(promptBpsPerMicrometer, 'Mean bp extensions (nm)', 1, defaultMeanBpExts_nm_strs);
                vectMeanBpExts_nm = cellfun(@str2double, answers_vectMeanBpExts_nm);
            end
            vectMeanBpExts_nm = vectMeanBpExts_nm(:);

            if length(vectMeanBpExts_nm) ~= numBarcodes
                fprintf('Aborting because barcode mean basepair extensions were not provided for all barcodes\n');
                stretchedBarcodes = {};
                stretchedKbpsPerPixel = [];
                return;
            end
            % Calculate kbp/pixel values
            vectKbpsPerPixel = vectDefaultPixelWidths_nm ./ (1000 * vectMeanBpExts_nm);

        elseif stretchToSameBpsPerPixelBasedOnLensInKbps
            vectDefaultBarcodeLens_kbps = barcodeLens_pixels .* vectDefaultPixelWidths_nm ./ (1000 * vectDefaultMeanBpExts_nm);

            if shouldImportFromFile
                import CBT.ExpComparison.Core.BarcodeLenNormalization.Helpers.Import.import_numeric_vector_from_textfile;
                vectBarcodeLens_kbps = import_numeric_vector_from_textfile('Select Text with Barcode Lens (Kbps)');
            else
                promptsBarcodeLens_kbps = barcodeNames;
                defaultBarcodeLens_kbps_strs = arrayfun(@num2str, vectDefaultBarcodeLens_kbps, 'UniformOutput', false);

                answers_vectBarcodeLens_kbps = inputdlg(promptsBarcodeLens_kbps, 'Barcode lengths (kbps)', 1, defaultBarcodeLens_kbps_strs);
                vectBarcodeLens_kbps = str2double(answers_vectBarcodeLens_kbps);
            end

            vectBarcodeLens_kbps = vectBarcodeLens_kbps(:);
            if length(vectBarcodeLens_kbps) ~= numBarcodes
                fprintf('Aborting because lengths were not provided for all barcodes\n');
                stretchedBarcodes = {};
                stretchedKbpsPerPixel = [];
                return;
            end
            % Calculate kbp/pixel values
            vectKbpsPerPixel = vectBarcodeLens_kbps ./ barcodeLens_pixels;
        end
        % Stretch all barcodes to the same kbp/pixel
        [sparsestKbpsPerPixel, ~] = min(vectKbpsPerPixel);
        stretchedKbpsPerPixel = repmat(sparsestKbpsPerPixel, [numBarcodes, 1]);
        vectStretchFactors = vectKbpsPerPixel ./ stretchedKbpsPerPixel;
    end


    if isempty(vectStretchFactors)
        fprintf('No length option was selected\n');
        stretchedBarcodes = {};
        stretchedKbpsPerPixel = [];
    else
        stretchedBarcodeLens_pixels = round(barcodeLens_pixels .* vectStretchFactors);
        import CBT.Core.sample_interp_to_len;
        stretchedBarcodes = arrayfun(...
            @(barcodeIdx) ...
                sample_interp_to_len(barcodes{barcodeIdx}, stretchedBarcodeLens_pixels(barcodeIdx), 'linear'), ...
                (1:numBarcodes)', ...
                'UniformOutput', false);
    end
end
