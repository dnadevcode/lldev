function [signalThreshold, errorMsg] = try_prompt_signal_threshold(defaultSignalThreshold)
    errorMsg = [];
    signalThreshold = NaN;
        % Ask user for a signal to noise ratio for accepting a detected molecule
    signalThresholdPrompt = 'Enter signal (above noise) threshold for molecule detection:';
    dlgTitle = 'Molecule detection parameter';
    answers = inputdlg(...
        {signalThresholdPrompt},...
        dlgTitle,...
        1,...
        {num2str(defaultSignalThreshold)}...
        );
    % Check to be sure there's some input at all.
    if not(isempty(answers))
        answer = str2double(answers{1});
                % Validate the inputs.
        if not(isnan(answer))       
            signalThreshold = answer;
        else
            errorMsg = 'Signal threshold was not a number';
        end

        % Parse the inputs.
    else
        errorMsg = 'A valid signal threshold was not provided';
    end
end
