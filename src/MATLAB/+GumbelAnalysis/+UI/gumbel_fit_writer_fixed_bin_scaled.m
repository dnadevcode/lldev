function [] = gumbel_fit_writer_fixed_bin_scaled(histValues, binWidth, useRecursiveApproachToGumbelFitting, alpha, tsvFilepath)
    if nargin < 1
        import GumbelAnalysis.Import.get_values_from_txt;
        [aborted, histValues] = get_values_from_txt('histogram values');
        if aborted
            return;
        end
    end

    if nargin < 2
        import Fancy.Validation.generate_validator;
        binWidthValidator = generate_validator({'scalar', {'>', 0}, {'<', 1}});
        defaultBinWidth = 0.02;
        import Fancy.UI.FancyInput.smart_input_dlg;
        [aborted, convertedValues] = smart_input_dlg(...
            {num2str(defaultBinWidth)}, {'Histogram Bin Width'}, 'Select subset length range (in basepairs)', [],...
            {binWidthValidator}, {@str2double}, [], [], []);
        if aborted
            return;
        end
        binWidth = convertedValues{1};
    end

    if nargin < 3
        useRecursiveApproachToGumbelFitting = 0;
        while useRecursiveApproachToGumbelFitting == 0
            useRecursiveApproachToGumbelFitting = menu('Do you want to use a recursive approach to gumbel fitting?',...
                'No, use non-recursive fitting',...
                'Yes, recursively exclude outliers based on an alpha');
        end
        useRecursiveApproachToGumbelFitting = (useRecursiveApproachToGumbelFitting == 2);

        if not(useRecursiveApproachToGumbelFitting)
            alpha = 0;
        else
            import GumbelAnalysis.Import.prompt_alpha;
            alpha = prompt_alpha();
        end
    end

    if nargin < 5
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        if useRecursiveApproachToGumbelFitting
            tsvFilepath = sprintf('recursiveGumbelCurve_%s.tsv', timestamp);
        else
            tsvFilepath = sprintf('nonrecursiveGumbelCurve_%s.tsv', timestamp);
        end
        [tsvFilename, tsvDipath, ~] = uiputfile('*.tsv', 'Save Gumbel Curve Data As', tsvFilepath);
        tsvFilepath = fullfile(tsvDipath, tsvFilename);
    end
    
    import GumbelAnalysis.Core.get_matches;
    [~, ~, gumbelCurveMusByIteration, gumbelCurveBetasByIteration, ~, ~] = get_matches(alpha, histValues(:)', 2);

    gumbelCurveBetaNonrecursive = gumbelCurveBetasByIteration{1};
    gumbelCurveMuNonrecursive = gumbelCurveMusByIteration{1};
    gumbelCurveBetaRecursive = gumbelCurveBetasByIteration{end};
    gumbelCurveMuRecursive = gumbelCurveMusByIteration{end};

    if useRecursiveApproachToGumbelFitting
        fprintf('Recursive Gumbel-fitting with alpha %g\n', alpha);
        gumbelCurveBeta = gumbelCurveBetaRecursive;
        gumbelCurveMu = gumbelCurveMuRecursive;
    else
        fprintf('Non-recursive Gumbel-fitting\n');
        gumbelCurveBeta = gumbelCurveBetaNonrecursive;
        gumbelCurveMu = gumbelCurveMuNonrecursive;
    end
    
    fprintf('Gumbel Curve: Mu=%g; Beta=%g\n', gumbelCurveMu, gumbelCurveBeta);
    halfBinWidth = binWidth/2;
    binCentersX = (0 + halfBinWidth):binWidth:(1 - halfBinWidth);
    binValuesY = hist(histValues, binCentersX);
    
    import GumbelAnalysis.Core.get_gumbel_curve;
    [gumbelCurveX, gumbelCurveY] = get_gumbel_curve(gumbelCurveMu, gumbelCurveBeta);
    curveScaleFactorY = sum(binValuesY*binWidth)/gumbelCurveBeta;
    fprintf('Gumbel Curve Rescaling factor: %g\n', curveScaleFactorY);
    gumbelCurveY = gumbelCurveY*curveScaleFactorY;
    s = struct;
    s.gumbelCurveX = gumbelCurveX;
    s.gumbelCurveY = gumbelCurveY;

    import Fancy.IO.TSV.write_tsv;
    write_tsv(tsvFilepath, s, fields(s));
    fprintf('Written to %s\n', tsvFilepath);
endend