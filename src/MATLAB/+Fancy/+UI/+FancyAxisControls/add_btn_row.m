function [hButtons] = add_btn_row(hParent, btnConfigs, btnLeftRightGapPx, btnPosPxBottomStart, btnPosPxLeftStart)
    % ADD_BTN_ROW - adds push buttons to a parent gui object in
    %   accordance with the configurations specified in a cell
    %   array of custom 1x1 structs where fields/values either
    %   specify button properties or are useful to calculate
    %   the button properties
    %
    % Inputs:
    %  hParent
    %    handle for the parent gui object on which to create the
    %      buttons as children
    %  btnConfigs
    %    custom configurations struct with certain potential fields
    %    for properties ('String', 'Callback', 'BackgroundColor',
    %    'FontSize') and potentially the fields 'z_WidthPx' and
    %    'z_HeightPx' specifying the desired height/width of the
    %    button  (note that having different heights for buttons in
    %    a row will likely be a bad idea)
    %  btnLeftRightGapPx (optional, defaults to 2)
    %    the gap in pixels between buttons
    %  btnPosPxBottomStart (optional, defaults to 2)
    %    the gap in pixels from the bottom of the buttons to the
    %    bottom of the parent
    %  btnPosPxLeftStart (optional, defaults to 2)
    %    the gap in pixels from the leftmost of the buttons to the
    %    left of the parent
    %
    % Outputs:
    %  hButtons
    %    handles to the created push buttons
    %
    % Authors:
    %   Saair Quaderi


    if nargin < 3
        btnLeftRightGapPx = 2;
    end
    if nargin < 4
        btnPosPxBottomStart = 2;
    end
    if nargin < 5
        btnPosPxLeftStart = 2;
    end
    import Fancy.Utils.merge_structs;
    import Fancy.Utils.extract_fields;
    
    
    btnPosPxBottom = btnPosPxBottomStart;
    btnPosPxLeft = btnPosPxLeftStart;
    allowedProps = {'Parent'; 'Style'; 'String'; 'Position'; 'Callback'; 'BackgroundColor'; 'FontSize'};

    numButtons = length(btnConfigs);
    hButtons = gobjects(numButtons, 1);
    for buttonNum=1:numButtons
        btnConfig = btnConfigs{buttonNum};
        btnWidthPx = btnConfig.z_WidthPx;
        btnHeightPx = btnConfig.z_HeightPx;
        btnPosPx = [btnPosPxLeft, btnPosPxBottom, btnWidthPx, btnHeightPx];
        btnConfig = merge_structs(btnConfig, struct(...
            'Parent', hParent,...
            'Style', 'pushbutton',...
            'Position', btnPosPx...
        ));
        btnPosPxLeft = btnPosPxLeft + btnWidthPx + btnLeftRightGapPx;

        propVals = cell(length(allowedProps), 1);
        [propVals{:}] = extract_fields(btnConfig, allowedProps);
        uicontrolArgs = reshape([allowedProps, propVals]', [2*length(allowedProps), 1]);
        hButtons(buttonNum) = uicontrol(uicontrolArgs{:});
    end
end