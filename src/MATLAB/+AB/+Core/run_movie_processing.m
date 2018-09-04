function [tmp_tsCurrMov, barcodes, barcodeDisplayNames, movieProcessingResultsStruct] = run_movie_processing(tsAB, movieDisplayName, gsMovObj, settings)
    
    % ------
    fprintf('Acquiring normalized movie\n');
    tic
    
    [~, movieIn] = gsMovObj.try_get_bounded_data(Microscopy.GrayscaleMovieStorageMode.Normalized);

    toc
    fprintf('Acquired normalized movie\n');

    
    
    import AB.Core.preprocess_movie_for_kymo_extraction;
    [kymosMolEdgeIdxs, movieRot, rRot, cRot, ccIdxs, ccStructNoEdgeAdj, rotationAngle] = preprocess_movie_for_kymo_extraction(movieIn, settings.preprocessing);


    
    
    % % ------
    % fprintf('Making kymograph label flipbooks\n');
    % tic
    % 
    % rotMovSz = size(movieRot);
    %
    % import AB.Core.gen_kymo_label_matrix;
    % labelFlipbook = gen_kymo_label_matrix(kymosEdgeIdxs, rotMovSz);
    %
    % import AB.UI.display_flipbooks;
    % display_flipbooks(labelFlipbook, movieRot);
    % 
    % toc
    % fprintf('Made kymograph label flipbooks\n');


    % ------
    fprintf('Translating kymograph edge coordinates\n');
    tic

    import AB.Core.translate_kymos_edge_coords;
    kymosEdgePts = translate_kymos_edge_coords(kymosMolEdgeIdxs, rRot, cRot);

    
    toc
    fprintf('Translated kymograph edge coordinates\n');
    
    % ------
    fprintf('Acquiring raw bounded video...\n');
    tic
    
    [~, tmp_movieArr, tmp_actualDiffArr] = gsMovObj.try_get_bounded_data(Microscopy.GrayscaleMovieStorageMode.RawApprox);
    
    toc
    fprintf('Acquired raw bounded video\n');
    
    
    % ------
    fprintf('Extracting kymos...\n');
    tic
    
    import AB.Core.extract_kymos;
    [layeredKymos, kymosMasks, kymosCenterXYCoords] = extract_kymos(tmp_movieArr, kymosEdgePts);
    tmp_numKymos = length(layeredKymos);
    tmp_roundedStartCenterCoords  = cellfun(@calc_approx_start_center, ...
        kymosCenterXYCoords, ...
        'UniformOutput', false);
    
    function roundedStartCenterCoords = calc_approx_start_center(kymosCenterXYCoord)
        frameIdx = 1;
        if not(isempty(kymosCenterXYCoord))
            roundedStartCenterCoords = round(kymosCenterXYCoord(frameIdx, 1:2));
        else
            roundedStartCenterCoords = [];
            disp('debug');
        end
    end
    
    tmp_kymoNameFormatStr = 'k_%03d_[%04d_%04d]';
    kymoDisplayNames = arrayfun(@(kymoNum) ...
        sprintf(tmp_kymoNameFormatStr, kymoNum, tmp_roundedStartCenterCoords{kymoNum}(1), tmp_roundedStartCenterCoords{kymoNum}(2)), ...
        (1:tmp_numKymos)', ...
        'UniformOutput', false);
    tmp_barcodeNameFormatStr = 'b_%03d_[%04d_%04d]';
    barcodeDisplayNames = arrayfun(@(kymoNum) ...
        sprintf(tmp_barcodeNameFormatStr, kymoNum, tmp_roundedStartCenterCoords{kymoNum}(1), tmp_roundedStartCenterCoords{kymoNum}(2)), ...
        (1:tmp_numKymos)', ...
        'UniformOutput', false); %#ok<NASGU>

    toc
    fprintf('Extracted kymos\n');

    % ------
    fprintf('Flattening layered kymos...\n');
    tic
    
    flattenedKymos = cell(tmp_numKymos, 1);
    for tmp_kymoIdx = 1:tmp_numKymos
        tmp_layeredKymo = layeredKymos{tmp_kymoIdx};
        tmp_flatKymo = mean(tmp_layeredKymo, 3);
        flattenedKymos{tmp_kymoIdx} = tmp_flatKymo;
    end
    
    toc
    fprintf('Flattened layered kymos\n');
    hTabCurrMov = tsAB.create_tab(movieDisplayName);
    tsAB.select_tab(hTabCurrMov);
    hPanelCurrMov = uipanel(hTabCurrMov);
    
    import Fancy.UI.FancyTabs.TabbedScreen;
    tmp_tsCurrMov = TabbedScreen(hPanelCurrMov);
    
    
    hTabFlattenedKymos = tmp_tsCurrMov.create_tab('Centered Kymos');
    tmp_tsCurrMov.select_tab(hTabFlattenedKymos);
    
    hPanelFlattenedKymos = uipanel(hTabFlattenedKymos);
    import OldDBM.Kymo.UI.show_kymos_in_grid;
    show_kymos_in_grid(hPanelFlattenedKymos, flattenedKymos, kymoDisplayNames);
    
    
    
    hTabFlattenedKymosMasks = tmp_tsCurrMov.create_tab('Centered Kymos Masks');
    tmp_tsCurrMov.select_tab(hTabFlattenedKymosMasks);
    
    hPanelFlattenedKymosMasks = uipanel(hTabFlattenedKymosMasks);
    import OldDBM.Kymo.UI.show_kymos_in_grid;
    show_kymos_in_grid(hPanelFlattenedKymosMasks, kymosMasks, kymoDisplayNames);
    
    

    % ------
    fprintf('Aligning flattened kymos...\n');
    tic
    
    import Fancy.UI.ProgressFeedback.BasicTextProgressMessenger;
    tmp_progress_messenger = BasicTextProgressMessenger.get_instance();
    tmp_msgOnInit = sprintf(' Aligning %d flattened kymos...\n', tmp_numKymos);
    tmp_progress_messenger.init(tmp_msgOnInit);
    
    flattenedKymosAligned = cell(tmp_numKymos, 1);
    kymoMasksAligned = cell(tmp_numKymos, 1);
    stretchFactorsMats = cell(tmp_numKymos, 1);
    skipPrealignTF = true;
    alignmentSuccessTFs = false(tmp_numKymos, 1);
    % forceEdgesTF = false;
    import OptMap.KymoAlignment.NRAlign.nralign;
    for tmp_kymoIdx = 1:tmp_numKymos
        tmp_flatKymo = flattenedKymos{tmp_kymoIdx};
        tmp_kymoMask = kymosMasks{tmp_kymoIdx};
        [tmp_alignedKymo, tmp_stretchFactorsMat, ~, tmp_alignedMask, ~, ~, tmp_alignmentSuccessTF] = nralign(tmp_flatKymo, skipPrealignTF, tmp_kymoMask);
        
        flattenedKymosAligned{tmp_kymoIdx} = tmp_alignedKymo;
        kymoMasksAligned{tmp_kymoIdx} = tmp_alignedMask;
        stretchFactorsMats{tmp_kymoIdx} = tmp_stretchFactorsMat;
        alignmentSuccessTFs(tmp_kymoIdx) = tmp_alignmentSuccessTF;
        
        tmp_progress_messenger.checkin(tmp_kymoIdx, tmp_numKymos);
    end
    
    tmp_msgOnCompletion = sprintf('    Finished aligning all %d kymos\n', tmp_numKymos);
    tmp_progress_messenger.finalize(tmp_msgOnCompletion);
    
    hTabAlignedFlattenedKymos = tmp_tsCurrMov.create_tab('Aligned Kymos');
    tmp_tsCurrMov.select_tab(hTabAlignedFlattenedKymos);
    
    hPanelAlignedFlattenedKymos = uipanel(hTabAlignedFlattenedKymos);
    import OldDBM.Kymo.UI.show_kymos_in_grid;
    show_kymos_in_grid(hPanelAlignedFlattenedKymos, flattenedKymosAligned, kymoDisplayNames);
    
    
    hTabAlignedFlattenedKymosMasks = tmp_tsCurrMov.create_tab('Aligned Kymos Masks');
    tmp_tsCurrMov.select_tab(hTabAlignedFlattenedKymosMasks);
    
    hPanelAlignedFlattenedKymosMasks = uipanel(hTabAlignedFlattenedKymosMasks);
    import OldDBM.Kymo.UI.show_kymos_in_grid;
    show_kymos_in_grid(hPanelAlignedFlattenedKymosMasks, kymoMasksAligned, kymoDisplayNames);
    
    
    toc
    fprintf('Aligned flattened kymos\n');
    
    % ------
    fprintf('Generating aligned kymo stats and barcodes...\n');
    tic
    
    tmp_msgOnInit = sprintf(' Processing stats for %d aligned kymo...\n', tmp_numKymos);
    tmp_progress_messenger.init(tmp_msgOnInit);
    
    meanAlignedKymos = cell(tmp_numKymos, 1);
    stdAlignedKymos = cell(tmp_numKymos, 1);
    meanAlignedMask = cell(tmp_numKymos, 1);
    barcodeEdges = NaN(tmp_numKymos, 2);
    barcodes = cell(tmp_numKymos, 1);
    
    
    import Microscopy.Utils.segment_nonadj_data;
    for tmp_kymoIdx = 1:tmp_numKymos
        tmp_alignmentSuccessTF = alignmentSuccessTFs(tmp_kymoIdx);
        if not(tmp_alignmentSuccessTF)
            continue;
        end
        tmp_alignedKymo = flattenedKymosAligned{tmp_kymoIdx};
        tmp_alignedMask = kymoMasksAligned{tmp_kymoIdx};
        tmp_alignedMaskMean = mean(double(tmp_alignedMask), 1);
        tmp_meanAlignedKymo  = mean(tmp_alignedKymo, 1, 'omitnan');
        tmp_stdAlignedKymo  = std(tmp_alignedKymo, 0, 1, 'omitnan');
        
        [~, tmp_idxRanges] = segment_nonadj_data(find(tmp_alignedMaskMean > 0));
        tmp_rangeLens = diff(tmp_idxRanges, [], 2) + 1;
        [~, tmpMaxRangeLenIdx] = max(tmp_rangeLens);
        barcodeEdges(tmp_kymoIdx, 1:2) = tmp_idxRanges(tmpMaxRangeLenIdx, 1:2);
        
        % Determine indices for rotated barcode with background cropped out
        tmp_adjustedIndices = barcodeEdges(tmp_kymoIdx, 1):barcodeEdges(tmp_kymoIdx, 2);
        tmp_barcode = tmp_meanAlignedKymo(tmp_adjustedIndices);
        
        % rawBarcode = zscore(rawBarcode);
        meanAlignedKymos{tmp_kymoIdx} = tmp_meanAlignedKymo;
        meanAlignedMask{tmp_kymoIdx} = tmp_alignedMaskMean;
        stdAlignedKymos{tmp_kymoIdx} = tmp_stdAlignedKymo;
        barcodes{tmp_kymoIdx} = tmp_barcode;
        
        tmp_progress_messenger.checkin(tmp_kymoIdx, tmp_numKymos);
    end
    
    tmp_msgOnCompletion = sprintf('    Processed stats for %d aligned kymo\n', tmp_numKymos);
    tmp_progress_messenger.finalize(tmp_msgOnCompletion);
    
    
    toc
    fprintf('Generated aligned kymo stats and barcodes\n');

    
    
    fprintf('Saving results to workspace...\n');
    tic

    %--------- FORMAT RESULTS
    if nargout > 3
        import Fancy.Utils.var2struct;
        % Hack to save all variables in current workspace as fields in a struct
        vars_to_save = feval(@(allvars) allvars(~strncmp('tmp_', allvars, 4)), who());
        movieProcessingResultsStruct = eval(['var2struct(', strjoin(vars_to_save, ', '),');']);
    end
    %#ok<*ASGLU>
    
    toc
    
end