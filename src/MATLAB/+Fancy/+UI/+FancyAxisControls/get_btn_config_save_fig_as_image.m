function saveFigBtnConfig = get_btn_config_save_fig_as_image(hFigure)
    % GET_BTN_CONFIG_SAVE_FIG_AS_IMAGE - get button
    %    property configurations in a custom struct format for
    %    a button that saves the figure as an image
    %
    % Inputs:
    %  hFigure
    %    handle for a figure object
    %
    % Outputs:
    %   saveFigBtnConfig
    %     property values for buttons related to saving a figure as
    %     an image (including callback)
    %
    % Authors:
    %   Saair Quaderi
    import Fancy.Utils.arg_swap;
    import Fancy.Utils.merge_structs;
    import Fancy.UI.PseudoScreenshot.get_figure_image_noui;
    import Fancy.UI.PseudoScreenshot.save_image;
    import Fancy.UI.FancyAxisControls.get_default_btn_config;

    callbackify = @arg_swap;

    btnText = 'Save As Image';
    fnSaveImage = callbackify(@() save_image(get_figure_image_noui(hFigure)));
    btnConfigDefaults = get_default_btn_config();
    saveFigBtnConfig = struct('String', btnText, 'Callback', fnSaveImage);
    saveFigBtnConfig = merge_structs(btnConfigDefaults, saveFigBtnConfig);
end