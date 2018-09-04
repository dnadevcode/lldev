function [hAxisCopy, hButtons] = print_view(hAxis)
    % PRINT_VIEW Clones an axis into a new figure from which
    %    it can be printed to an image file with more ease
    %
    % Inputs:
    %  hAxis
    %    the handle of the axis to place in a print view figure
    %
    % Outputs:
    %  hAxisCopy
    %    the handle of the axis copy in the print view figuure
    %  hButtons
    %    the handles of any buttons available in the print view
    %    (e.g. "save as")
    %
    % Authors:
    %   Saair Quaderi

    import Fancy.Utils.merge_structs;
    import Fancy.Utils.extract_fields;
    import Fancy.UI.FancyPositioning.maximize_figure_or_make_big;
    import Fancy.UI.FancyAxisControls.get_btn_config_save_fig_as_image;
    import Fancy.UI.FancyAxisControls.add_btn_row;
    btnConfigGetter.save_fig_as_image = @get_btn_config_save_fig_as_image;

    validateattributes(hAxis, {'matlab.graphics.axis.Axes'}, {'scalar'});

    hFigNew = figure('Name', 'Print View');
    maximize_figure_or_make_big(hFigNew);
    hPanelNew = uipanel('Parent', hFigNew, 'BackgroundColor', [1 1 1]);
    hAxisCopy = copyobj(hAxis, hPanelNew);

    btnConfigs = {...
        btnConfigGetter.save_fig_as_image(hFigNew)...
        %others could be added here if more buttons were desired
        };

    [hButtons] = add_btn_row(hPanelNew, btnConfigs);
end