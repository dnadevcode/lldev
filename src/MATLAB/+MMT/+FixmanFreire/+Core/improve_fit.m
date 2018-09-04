function [vectA, vectB] = improve_fit(vectA, vectB, vectN, loopExponent)
    maxExpansionTermIdx = length(vectA);
    for expansionTermIdx = maxExpansionTermIdx:-1:1
        oldValA = vectA(expansionTermIdx);
        oldValB = vectB(expansionTermIdx);
        vectA(expansionTermIdx) = 0;
        vectB(expansionTermIdx) = 0;
        nVal1 = vectN(2 * expansionTermIdx - 1);
        nVal2 = vectN(2 * expansionTermIdx);
        sumApprox1 = sum(vectA.*exp(-nVal1 * vectB));
        sumApprox2 = sum(vectA.*exp(-nVal2 * vectB));
        gVal1 = nVal1^(-loopExponent);
        gVal2 = nVal2^(-loopExponent);
        if (sumApprox1 >= gVal1) || (sumApprox2 >= gVal2)
            vectA(expansionTermIdx) = oldValA;
            vectB(expansionTermIdx) = oldValB;
        else
            diff1 = gVal1 - sumApprox1;
            diff2 = gVal2 - sumApprox2;
            bVal = (log(diff1) - log(diff2))/(nVal2 - nVal1);
            aVal = diff2/exp(-bVal * nVal2);
            vectA(expansionTermIdx) = aVal;
            vectB(expansionTermIdx) = bVal;
        end
    end
end