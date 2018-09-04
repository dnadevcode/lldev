function [] = show_kymos(kymos, hAxesKymos, headerTexts)
    if nargin < 3
        headerTexts = [];
    end
    
    numKymos = numel(kymos);
    for kymoNum = 1:numKymos
        kymo = kymos{kymoNum};
        hAxisKymo = hAxesKymos(kymoNum);
        
        axes(hAxisKymo); %#ok<LAXES>
        imagesc(kymo);
        colormap(hAxisKymo, gray());
        set(hAxisKymo, ...
            'XTick', [], ...
            'YTick', []);
        box(hAxisKymo, 'on');
    end
    
    if not(isempty(headerTexts))
        import OldDBM.General.UI.set_centered_header_text;
        for kymoNum = 1:numKymos
            headerText = headerTexts{kymoNum};
            hAxisKymo = hAxesKymos(kymoNum);
            axes(hAxisKymo); %#ok<LAXES>
            set_centered_header_text(hAxisKymo, headerText, [1 1 0], 'none');
        end
    end
end