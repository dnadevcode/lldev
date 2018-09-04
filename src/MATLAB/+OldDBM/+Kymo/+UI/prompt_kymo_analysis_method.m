function [kymoAnalysisMethod, shouldSaveTF] = prompt_kymo_analysis_method()
    screenSize = get(0, 'ScreenSize');

    hFig = figure(...
        'Name', 'Pick a Method', ...
        'Visible', 'off', ...
        'MenuBar', 'none', ...
        'Position', [round(screenSize(3)/2) round(screenSize(4)/2) 350 200], ...
        'Resize', 'off');

    kymoAnalysisMethod = '';
    shouldSaveTF = false;
    function fn_callback(kymoAnalysisMethodChosen, shouldSaveTFChosen)
        kymoAnalysisMethod = kymoAnalysisMethodChosen;
        shouldSaveTF = shouldSaveTFChosen;
    end

    import OldDBM.Kymo.UI.async_prompt_kymo_analysis_method;
    async_prompt_kymo_analysis_method(hFig, @fn_callback);
    uiwait(hFig);
end