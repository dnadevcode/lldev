function [vectA, vectB] = calc_fixman_freire_coeffs()
    import MMT.FixmanFreire.UI.prompt_num_iterations;
    import MMT.FixmanFreire.UI.prompt_num_expansion_terms;
    import MMT.FixmanFreire.UI.prompt_loop_exponent;
    import MMT.FixmanFreire.UI.prompt_n_vect;
    import MMT.FixmanFreire.UI.prompt_should_continue_fitting;
    import MMT.FixmanFreire.Core.improve_fit;
    if nargin < 1
        numIterations = 30000;
        loopExponent = 2.15;
        numExpansionTerms = 15;
        vectN = exp(linspace(log(1), log(800000), 2*numExpansionTerms))';
    end
%     [aborted, numIterations] = prompt_num_iterations();
%     if aborted
%         return;
%     end
%     
%     [aborted, loopExponent] = prompt_loop_exponent();
%     if aborted
%         return;
%     end
%     
%     [aborted, numExpansionTerms] = prompt_num_expansion_terms();
%     if aborted
%         return;
%     end
%     
%     [aborted, vectN] = prompt_n_vect(numExpansionTerms);
%     if aborted
%         return;
%     end
    
    
    shouldContinueTF = true;
    vectA = zeros(numExpansionTerms, 1);
    vectB = zeros(numExpansionTerms, 1);
    strIdxVect = arrayfun(@num2str, (1:numExpansionTerms)', 'UniformOutput', false);
    
    
    while shouldContinueTF
        for iterationNum = 1:numIterations
            [vectA, vectB] = improve_fit(vectA, vectB, vectN, loopExponent);
        end
        strVectA = arrayfun(@(a) sprintf('%.20f', a), vectA, 'UniformOutput', false);
        strVectB = arrayfun(@(b) sprintf('%.20f', b), vectB, 'UniformOutput', false);
        tableAB = table(strVectA, strVectB, 'VariableNames', {'a', 'b'}, 'RowNames', strIdxVect);
        disp(tableAB);
        %shouldContinueTF = prompt_should_continue_fitting();
        shouldContinueTF = false;
    end
    
    strVectA = arrayfun(@(a) sprintf('%.20f', a), vectA, 'UniformOutput', false);
    strVectB = arrayfun(@(b) sprintf('%.20f', b), vectB, 'UniformOutput', false);
    tableAB = table(strVectA, strVectB, 'VariableNames', {'a', 'b'}, 'RowNames', strIdxVect);
    disp(tableAB); 
end