function [] = plot_curves(hAxis, curves, curvesIndices, alignedBitmasks, strLineSpecs)
    
   % Plot everything
   % A bit complicated because of the "gap" in the shorter barcode

    hold(hAxis, 'on');
    
    for idx = 1:2
        curve = curves{idx};
        curve = curve(:);
        
        curveIndices = curvesIndices{idx};
        curveIndices = curveIndices(:);
        
        alignedBitmask = alignedBitmasks{idx};
        alignedBitmask = alignedBitmask(:);
        
        strLineSpec = strLineSpecs{idx};
        
        
        plot_helper(hAxis, curve, curveIndices, alignedBitmask, strLineSpec, 1);
    end
    
    function [] = plot_helper(hAxis, curve, curveIndices, alignedBitmask, strLineSpec, lineWidth)
        curveVals = curve(curveIndices);
        idxIdxs = 1:length(curveIndices);
        indices = idxIdxs(alignedBitmask);
        curve = curveVals(alignedBitmask);
        
        compEdges = [0, find(abs(diff(indices)) ~= 1), length(indices)];
        compEdges = [compEdges(1:(end-1)) + 1; compEdges(2:end)];
        for compNum = 1:size(compEdges, 2)
            compLeftIndex = compEdges(1, compNum);
            compRightIndex = compEdges(2, compNum);
            compIndices = compLeftIndex:compRightIndex;
            plot(hAxis, indices(compIndices), curve(compIndices), strLineSpec, 'LineWidth', lineWidth);
        end
    end

end