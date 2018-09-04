function alpha = prompt_alpha()
    defaultAlpha = 0.0005;
    defaultAnswer = num2str(defaultAlpha);
    answer = '';
    while not(isnumeric(answer)) || isnan(answer)
        answers = inputdlg('Confidence Interval Value Required for Match (alpha)', 'Confidence Interval', 1, {defaultAnswer});
        if iscell(answers) && not(isempty(answers))
            answers = answers{1};
        end
         answer = answers;
        if ischar(answer)
            answer = str2double(answer);
        end
    end
    alpha = answer;
end