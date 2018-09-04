function [] = execute(...
        tsSVD,...
        hEditSelectFile1, hEditSelectFile2, ...
        hEditSelectLength1, hEditSelectLength2, ...
        hRadioButton1, hRadioButton2, hRadioButton3, hRadioButton4, hRadioButton5, ...
        hMVMParamBox1,...
        hLCMAParamBox1, hLCMAParamBox2, hLCMAParamBox3, hLCMAParamBox4,...
        hCheckboxUseNeighbors, hEditNeighborWeight, hCheckboxUsePCC)
    
    %Initiation:
    seqFilepath1 = get(hEditSelectFile1, 'String');
    seqFilepath2 = get(hEditSelectFile2, 'String');
    
    import SVD.Import.import_curve_from_filepath;
    seq1 = import_curve_from_filepath(seqFilepath1);
    seq2 = import_curve_from_filepath(seqFilepath2);

    import Barcoding.Helpers.resize;
    if str2double(get(hEditSelectLength1, 'String')) > 0
        seq1 = resize(seq1, 1000*str2double(get(hEditSelectLength1, 'String')));
    end
    if str2double(get(hEditSelectLength1, 'String')) > 0
       seq2 = resize(seq2, 1000*str2double(get(hEditSelectLength2, 'String')));
    end
    seq1 = zscore(seq1);
    seq2 = zscore(seq2);
    
    useNeighborhoodTF = (hCheckboxUseNeighbors.Value == 1);
    usePccTF = (hCheckboxUsePCC.Value == 1);
    if (useNeighborhoodTF || usePccTF)
        dist = round(str2double(get(hEditNeighborWeight, 'String')));
    else
        dist = 0;
    end

    useDTWMethodTF = (hRadioButton1.Value == 1);
    useMVMMethodTF = (hRadioButton2.Value == 1);
    useALCMASDMethodTF = (hRadioButton3.Value == 1);
    useLAPMethodTF = (hRadioButton4.Value == 1);
    useHMMMethodTF = (hRadioButton5.Value == 1);

    if length(seq2) < length(seq1)
        [seqShorter, seqLonger] = deal(seq2, seq1);
    else
        [seqShorter, seqLonger] = deal(seq1, seq2);
    end
    refSeq = seqLonger;
    warpedSeq = seqShorter;

    
    hTabSVDResults = tsSVD.create_tab('SVD Results');
    hPanelSVDResults = uipanel('Parent', hTabSVDResults);
    
    import Fancy.UI.FancyTabs.TabbedScreen;
    tsSVDResults = TabbedScreen(hPanelSVDResults);
    
    
    hTabCostMat = tsSVDResults.create_tab('Cost Matrix');
    hPanelCostMat = uipanel('Parent', hTabCostMat);
    hAxisCostMat = axes('Parent', hPanelCostMat);
    
    hTabAlignment = tsSVDResults.create_tab('Alignment');
    hPanelAlignment = uipanel('Parent', hTabAlignment);
    hAxisAlignment = axes('Parent', hPanelAlignment);
    
    %Detects and executes method:
    if useDTWMethodTF %DTW
        import SVD.run_dtw_method;
        run_dtw_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, hAxisCostMat, hAxisAlignment)
    elseif useMVMMethodTF
        mvmWinWidth = str2double(get(hMVMParamBox1, 'String'));

        import SVD.run_mvm_method;
        run_mvm_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, mvmWinWidth, hAxisCostMat, hAxisAlignment);
    elseif useALCMASDMethodTF %A-LCMA-SD
        bandWidth = str2double(get(hLCMAParamBox1, 'String'));
        lengthParam = str2double(get(hLCMAParamBox2, 'String'));
        lcmaThresholdZeroDist = str2double(get(hLCMAParamBox3, 'String'));
        numBestPaths = str2double(get(hLCMAParamBox4, 'String'));

        import SVD.run_A_LCMA_SD_method;
        run_A_LCMA_SD_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, bandWidth, lengthParam, lcmaThresholdZeroDist, numBestPaths, hAxisCostMat, hAxisAlignment);
    elseif useLAPMethodTF
        import SVD.run_lap_method;
        run_lap_method(warpedSeq, refSeq, useNeighborhoodTF, usePccTF, dist, hAxisCostMat, hAxisAlignment);
    elseif useHMMMethodTF
        hTabComparison = tsSVDResults.create_tab('Comparison');
        hPanelComparison = uipanel('Parent', hTabComparison);
        hAxisComparison = axes('Parent', hPanelComparison);
        
        hTabResTable = tsSVDResults.create_tab('Results Table');
        hPanelResTable = uipanel('Parent', hTabResTable);
        hTableResTable = uitable('Parent', hPanelResTable);
        
        import SVD.run_hmm_method;
        run_hmm_method(seq1, seq2, hAxisCostMat, hAxisAlignment, hAxisComparison, hTableResTable);
    end
end
