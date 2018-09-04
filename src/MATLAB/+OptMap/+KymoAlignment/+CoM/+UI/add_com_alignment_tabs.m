%=========================================================================%
function [] = add_com_alignment_tabs(ts, rawKymos)			     
    % ADD_COM_ALIGNMENT_TABS - Takes raw kymographs and 
    %   aligns each time frame to the center-of-mass (actually foreground
    %  intensity) and then makes  1D intensity profiles from them.
    %
    % Inputs:
    %   ts
    %     tabbed screen
    %   rawKymos
    %     cell array of raw kymographs
    %
    % Authors:
    %   Saair Quaderi
    %   Tobias Ambjörnsson (original version)

    % if nargin < 1
    %     hFig = figure('Name', 'Center of Mass Aligned Time Traces');
    %     hPanel = uipanel('Parent', hFig);
    %     import Fancy.UI.FancyTabs.TabbedScreen;
    %     ts = TabbedScreen(hPanel);
    % end
    if nargin < 2
        % TODO: get kymos from some prompt
        rawKymos = cell(0, 1);
    end
    if isempty(rawKymos)
        fprintf('No kymographs!\n');
    end
    
    hTabCoM = ts.create_tab('Center of Mass Aligned Kymos');
    hPanelCOM = uipanel('Parent', hTabCoM);
    tsCoM = TabbedScreen(hPanelCOM);
    
    rawKymos = rawKymos(:);
    
    rawKymoFgMasks = cellfun(...
        @(rawKymo) ...
            (imquantize(rawKymo, multithresh(rawKymo,1)) > 1), ...
        rawKymos, ...
        'UniformOutput', false);
    
    meanBgLevels = cellfun(...
        @(rawKymo, rawKymoFgMask) ...
            mean(rawKymo(~rawKymoFgMask)), ...
        rawKymos, rawKymoFgMasks);
    
    import OptMap.KymoAlignment.CoM.Core.zeroify_raw_kymo_bg;
    rawKymosBgZeroed = cellfun(...
        @zeroify_raw_kymo_bg, ...
        rawKymos, rawKymoFgMasks, num2cell(meanBgLevels), ...
        'UniformOutput', false);

    import OptMap.KymoAlignment.CoM.Core.compute_center_of_mass;
    centersOfMass = cellfun(@compute_center_of_mass, ...
        rawKymosBgZeroed);

    import OptMap.KymoAlignment.CoM.Core.center_of_mass_align_kymo;
    comAlignedKymos = cellfun(@center_of_mass_align_kymo, ...
        rawKymos, num2cell(centersOfMass), ...
        'UniformOutput', false);
    
    numKymos = length(rawKymos);
    for kymoNum = 1:numKymos
        rawKymo = rawKymos{kymoNum};
        rawKymoBgZeroed = rawKymosBgZeroed{kymoNum};
        centerOfMass = centersOfMass(kymoNum);
        comAlignedKymo = comAlignedKymos{kymoNum};
        
        tabTitle = sprintf('Kymo %d', kymoNum);
        hTab = tsCoM.create_tab(tabTitle);
        hTabPanel = uipanel('Parent', hTab);
        tsCoMKymo = TabbedScreen(hTabPanel);
        
        % Show the kymograph with background removed
        import OptMap.KymoAlignment.CoM.UI.add_bg_zeroed_kymo_tab;
        add_bg_zeroed_kymo_tab(tsCoMKymo, rawKymoBgZeroed);

        % Show single time trace (e.g. for first frame)
        frameNumSTT = 1;
        import OptMap.KymoAlignment.CoM.UI.add_single_time_trace_tab;
        add_single_time_trace_tab(tsCoMKymo, rawKymo, rawKymoBgZeroed, frameNumSTT);
        
        % Show raw kymograph with center of mass on top
        import OptMap.KymoAlignment.CoM.UI.add_bg_com_tab;
        add_bg_com_tab(tsCoMKymo, rawKymo, centerOfMass);
    
        % Show the center of mass aligned kymograph
        import OptMap.KymoAlignment.CoM.UI.add_com_aligned_kymo_tab;
        add_com_aligned_kymo_tab(tsCoMKymo, comAlignedKymo)
    end
end