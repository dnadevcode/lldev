function [aborted, loopExponent] = prompt_loop_exponent()
    inputStr = input('Loop exponent (c)? ','s');
    if isempty(inputStr)
        aborted = true;
        loopExponent = NaN;
        disp('Aborting');
    else
        loopExponent = str2double(inputStr);
        if isnan(loopExponent)|| not(isfinite(loopExponent))
            disp('Please enter a finite number for the loop exponent!');
            [aborted, loopExponent] = prompt_loop_exponent();
        else
            aborted = false;
        end
    end
end