function [defaultBtnConfig] = get_default_btn_config()
    % GET_DEFAULT_BTN_CONFIG - returns the default button
    % property configurations in a custom struct format
    %
    % Outputs:
    %   defaultBtnConfig
    %     default property values for buttons related to some fancy
    %     features
    %
    % Authors:
    %   Saair Quaderi

    import Fancy.Utils.nop;

    % the "z_" prefix is just our custom way of specifying info
    %  that isn't directly a property but will possibly effect one
    %  via some computations
    defaultBtnConfig = struct(...
        'z_WidthPx', 80,...
        'z_HeightPx', 32,...
        'ForegroundColor', [0, 0, 0],...
        'BackgroundColor', [1, 1, 1],...
        'FontSize', 7,...
        'Callback', @nop...
        );
end