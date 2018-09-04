function [ctrlStruct] = demo_dyn_btn_adding()
    % DEMO_DYN_BTN_ADDING - Demos adding buttons dynamically
    %
    % Outputs:
    %  ctrlStruct
    %    a struct that provides the following:
    %      fn.add_button: handle to a function that takes
    %        buttonText, fnButtonCallback, btnConfigsCustom as input
    %        where text is what the button's text says, fnButtonCallback
    %        is optional and is the action to perform when the button is
    %        clicked, and btnConfigsCustom is a struct that allows the
    %        setting of properties for the button like 'FontSize', 
    %        'ForegroundColor', and 'BackgroundColor', etc.
    %
    % Authors:
    %   Saair Quaderi
    
    import Fancy.Utils.arg_swap;
    import Fancy.UI.FancyPositioning.maximize_figure_or_make_big;

    callbackify = @arg_swap;
    hFigNew = figure('Name', 'Demo Button Addition');
    hParent = hFigNew;
    maximize_figure_or_make_big(hFigNew);

    btnConfigDefaults = struct(...
       'z_WidthPx', 80,...
       'z_LeftGapPx', 2, ...
       'z_RightGapPx', 2, ...
       'z_HeightPx', 32,...
       'FontSize', 7,...
       'ForegroundColor', [0, 0, 0],...
       'BackgroundColor', [1, 1, 1]...
    );
    btnConfigReqs = struct(...
       'Parent', hParent... %common parent
    );
    initBtnConfigs = struct(...
        'z_StartLeftPosPx', 2, ...
        'z_StartBottomPosPx', 2 ...
    );

    myButtons = gobjects(0,1);
    myButtonConfigs = cell(0,1);

    function add_button(buttonText, fnButtonCallback, btnConfigsCustom)
        import Fancy.Utils.merge_structs;
    
        if nargin < 2
            fnButtonCallback = @(~, ~, ~) 0;
        end
        if nargin < 3
            btnConfigsCustom = struct;
        end
        btnConfigs = merge_structs(btnConfigDefaults, btnConfigsCustom, btnConfigReqs);
        widthPx = btnConfigs.z_WidthPx;
        heightPx = btnConfigs.z_HeightPx;
        leftGapPx = btnConfigs.z_LeftGapPx;
        numOldButtons = numel(myButtons);
        if numOldButtons == 0
            bottomPosPx = initBtnConfigs.z_StartBottomPosPx;
            leftPosPx = initBtnConfigs.z_StartLeftPosPx;
        else
            lastBtnConfig =  myButtonConfigs{numOldButtons};
            lastPosPx = getpixelposition(myButtons(numOldButtons));
            lastLeftPosPx = lastPosPx(1);
            lastBottomPosPx = lastPosPx(2);
            lastWidthPx = lastPosPx(3);
            % lastHeightPx = lastPosPx(4);
            lastRightPosPx = lastLeftPosPx + lastWidthPx;
            lastRightGapPx = lastBtnConfig.z_RightGapPx;

            bottomPosPx = lastBottomPosPx;
            leftPosPx = lastRightPosPx + lastRightGapPx + leftGapPx;
        end

        myButtons(numOldButtons + 1) = uicontrol(...
            'Parent', btnConfigs.Parent,...
            'Style', 'pushbutton',...
            'BackgroundColor', btnConfigs.BackgroundColor,...
            'ForegroundColor', btnConfigs.ForegroundColor,...
            'FontSize', btnConfigs.FontSize,...
            'Position', [leftPosPx, bottomPosPx, widthPx, heightPx],...
            'String', buttonText,...
            'Callback', fnButtonCallback);
        myButtonConfigs{numOldButtons + 1} = btnConfigs;

    end
    ctrlStruct.fn.add_button = @add_button;
    ctrlStruct.fn.add_button('Say Hello', callbackify(@() msgbox('Hello')));
    ctrlStruct.fn.add_button('Say Bye', callbackify(@() msgbox('Bye')), struct('ForegroundColor', [1, 0, 0], 'BackgroundColor', [0, 0, 0]));
end