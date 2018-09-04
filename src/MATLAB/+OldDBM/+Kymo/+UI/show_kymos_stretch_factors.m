function [] = show_kymos_stretch_factors(kymosStretchFactors, hAxesKymosStretchFactors, headerTexts)
    import OldDBM.General.UI.set_centered_header_text;
    
    numKymos = numel(kymosStretchFactors);
    for kymoNum = 1:numKymos
        kymoStretchFactors = kymosStretchFactors{kymoNum};
        headerText = headerTexts{kymoNum};
        hAxisKymoStretchFactors = hAxesKymosStretchFactors(kymoNum);
        
        axes(hAxisKymoStretchFactors); %#ok<LAXES>
        imagesc(kymoStretchFactors);
        colormap(hAxisKymoStretchFactors, hot());
        set(hAxisKymoStretchFactors, ...
            'XTick', [], ...
            'YTick', []);
        box(hAxisKymoStretchFactors, 'on');

        set_centered_header_text(hAxisKymoStretchFactors, headerText, [1 1 0], 'none');
    end
end