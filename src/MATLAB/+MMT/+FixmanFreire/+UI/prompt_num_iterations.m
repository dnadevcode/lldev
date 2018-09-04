function [aborted, numIterations] = prompt_num_iterations()
    inputStr = input('How many iterations? ','s');
    if isempty(inputStr)
        aborted = true;
        numIterations = NaN;
        disp('Aborting');
    else
        numIterations = str2double(inputStr);
        if isnan(numIterations) || (floor(numIterations) ~= numIterations) || (numIterations < 1) || not(isreal(numIterations))|| not(isfinite(numIterations))
            disp('Please enter a positive finite integer for the number of iterations!');
            [aborted, numIterations] = prompt_num_iterations();
        else
            aborted = false;
        end
    end
end