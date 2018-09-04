function dataStruct = plot_theory_and_theory(hAxis, thyStructA, thyStructB, stretchFactor, settingsParams)
    import CBT.TheoryComparison.Core.generate_alignment_for_theory_and_theory;
    [~, ~, alignedCurveABitmask, alignedCurveBBitmask, alignedCurveAIndices, alignedCurveBIndices, curveA_pxRes, curveB_pxRes] = generate_alignment_for_theory_and_theory(thyStructA, thyStructB, stretchFactor, settingsParams);
    
    if not(any(alignedCurveABitmask)) || not(any(alignedCurveBBitmask))
        warning('No curve values were included for at least one of the curves');
    end
    
    curves = {curveA_pxRes; curveB_pxRes};
    curvesIndices = {alignedCurveAIndices; alignedCurveBIndices};
    alignedBitmasks = {alignedCurveABitmask, alignedCurveBBitmask};
    strLineSpecs = {'r-'; 'b-'};
    
    import CBT.TheoryComparison.UI.plot_curves;
    plot_curves(hAxis, curves, curvesIndices, alignedBitmasks, strLineSpecs);

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