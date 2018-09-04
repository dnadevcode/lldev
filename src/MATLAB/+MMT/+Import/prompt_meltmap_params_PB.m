function [paramsAreValid, temperatures_Celsius, bc, gamma] = prompt_meltmap_params_PB()
    paramsAreValid = false;
    temperatures_Celsius = [];
   % sharedSaltConc_molar = [];

    % Get the model parameters from the user.
    dialogTitle = 'Meltmap Parameters';
    prompts = {...
        'Temp (C):',...
        'bc :', ...
        'Gamma :'};
    numLines = 1;
    defaultAnswers = {...
        num2str(43.0); ...
        'closed'; ...
        num2str(-0.042) ...
        };
    answers = inputdlg(prompts, dialogTitle, numLines, defaultAnswers);

    % Check to be sure there's some input at all.
    if isempty(answers)
        return;
    end

    % Parse the inputs.
    temperatureStart = 273.15+ str2double(answers{1});
   % temperatureEnd = str2double(answers{2});
   % temperatureStepSize = str2double(answers{3});
    bc = answers{2};
    gamma = str2double(answers{3});

    temperatures_Celsius = [];
    try
        temperatures_Celsius = temperatureStart;
    catch
    end

    if isempty(temperatures_Celsius) || any(isnan(temperatures_Celsius))
        disp('Invalid temperature settings');
    elseif isnan(gamma)
        disp('Invalid gamma setting');
    else
        paramsAreValid = true;
    end
end