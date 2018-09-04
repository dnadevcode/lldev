function [paramsAreValid, temperatures_Celsius, sharedSaltConc_molar] = prompt_meltmap_params_PS(sharedSaltConc_molar,temperatures_Celsius)
    paramsAreValid = false;
%     temperatures_Celsius = [];
%     sharedSaltConc_molar = [];

    % Get the model parameters from the user.
    dialogTitle = 'Meltmap Parameters';
    prompts = {...
        'Melting temperature (C):', ...
     %   'End temperature (C):', ...
      %  'Temperature step-size:', ...
        'Salt concentration (M):'};
    numLines = 1;
    defaultAnswers = {...
        num2str(temperatures_Celsius); ...
       % num2str(62.0); ...
       % num2str(0.5); ...
        num2str(sharedSaltConc_molar) ...
        };
    answers = inputdlg(prompts, dialogTitle, numLines, defaultAnswers);

    % Check to be sure there's some input at all.
    if isempty(answers)
        return;
    end

    % Parse the inputs.
    temperatureStart = str2double(answers{1});
   % temperatureEnd = str2double(answers{2});
   % temperatureStepSize = str2double(answers{3});
    sharedSaltConc_molar = str2double(answers{2});

    temperatures_Celsius = [];
    try
        temperatures_Celsius = temperatureStart;
    catch
    end

    if isempty(temperatures_Celsius) || any(isnan(temperatures_Celsius))
        disp('Invalid temperature settings');
    elseif isnan(sharedSaltConc_molar)
        disp('Invalid salt concentration settings');
    else
        paramsAreValid = true;
    end
end