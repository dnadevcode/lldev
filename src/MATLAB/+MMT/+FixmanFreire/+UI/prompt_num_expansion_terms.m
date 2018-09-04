function [aborted, numExpansionTerms] = prompt_num_expansion_terms()
    inputStr = input('How many expansion terms? ','s');
    if isempty(inputStr)
        aborted = true;
        numExpansionTerms = NaN;
        disp('Aborting');
    else
        numExpansionTerms = str2double(inputStr);
        if isnan(numExpansionTerms) || (fix(numExpansionTerms) ~= numExpansionTerms) || (numExpansionTerms < 1) || not(isreal(numExpansionTerms))|| not(isfinite(numExpansionTerms))
            disp('Please enter a positive finite integer number for the number of expansion terms!');
            [aborted, numExpansionTerms] = prompt_num_expansion_terms();
        else
            aborted = false;
        end
    end
end