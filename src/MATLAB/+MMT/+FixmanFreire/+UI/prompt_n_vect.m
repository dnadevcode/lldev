function [aborted, vectN] = prompt_n_vect(numExpansionTerms)
    minN = 1;
    fprintf('Minimum n: %d\n', minN);

    inputStr = input('Maximum n? ','s');
    if isempty(inputStr)
        aborted = true;
        vectN = [];
        disp('Aborting');
    else
        maxN = str2double(inputStr);
        if isnan(maxN)|| not(isfinite(maxN)) || (maxN <= minN)
          disp('Please enter a finite number greater than the minimum n for the maximum n!');
          [aborted, vectN] = prompt_n_vect(numExpansionTerms);
        else
            aborted = false;
            vectN = exp(linspace(log(minN), log(maxN), 2*numExpansionTerms))';
        end
    end
end