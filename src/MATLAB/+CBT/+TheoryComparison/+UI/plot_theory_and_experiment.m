function dataStruct = plot_theory_and_experiment(hAxis, thyStruct, expStruct, stretchFactor, settingsParams)
    import CBT.TheoryComparison.Core.generate_alignment_for_theory_and_experiment;
    [~, ~, alignedCurveABitmask, alignedCurveBBitmask, alignedCurveAIndices, alignedCurveBIndices, curveA_pxRes, curveB_pxRes] = generate_alignment_for_theory_and_experiment(thyStruct, expStruct, stretchFactor, settingsParams,1);
    try
    [~, ~, alignedCurveABitmask, alignedCurveBBitmask, alignedCurveAIndices, alignedCurveBIndices, curveA2_pxRes, ~] = generate_alignment_for_theory_and_experiment(thyStruct, expStruct, stretchFactor, settingsParams,2);
    catch
       % in this case no binding curve exists.. 
    end
    if not(any(alignedCurveABitmask)) || not(any(alignedCurveBBitmask))
        warning('No curve values were included for at least one of the curves');
    end
    
    curves = {curveA_pxRes; curveB_pxRes};
    curvesIndices = {alignedCurveAIndices; alignedCurveBIndices};
    alignedBitmasks = {alignedCurveABitmask, alignedCurveBBitmask};
    strLineSpecs = {'r-'; 'b-'};
    
    import CBT.TheoryComparison.UI.plot_curves;
    plot_curves(hAxis, curves, curvesIndices, alignedBitmasks, strLineSpecs);
    try
        [val,pos] = max(curveA2_pxRes);
    plot(  find(curvesIndices{1}==pos),curveA_pxRes(pos),'blacko','linewidth',5)
    catch
    end
    fieldNames = {'curveA'; 'curveB'};
    dataStruct = struct();
    for idx = 1:2
        fieldName = fieldNames{idx};
        
        curve = curves{idx};
        curve = curve(:);
        
        curveIndices = curvesIndices{idx};
        curveIndices = curveIndices(:);
        
        alignedBitmask = alignedBitmasks{idx};
        alignedBitmask = alignedBitmask(:);
        
        
        curveValsOut = curve(curveIndices);
        curveValsOut(~alignedBitmask) = NaN;
        curveValsNanmask = isnan(curveValsOut);
        curveValsOut = num2cell(curveValsOut);
        curveValsOut(curveValsNanmask) = cell(sum(curveValsNanmask), 1);
        dataStruct.(fieldName) = curveValsOut;
    end
end