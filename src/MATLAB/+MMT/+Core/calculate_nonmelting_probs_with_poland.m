function [probsNonmelted] = calculate_nonmelting_probs_with_poland(seqWeightsHydrogenBonds, seqWeightsStackingInteraction, loopExponentC)
    % loopExponentC = 1.76; % c, for self-avoiding loop with continuous transition (possibly more approriate value when DNA is relatively confined)
    % loopExponentC = 2.11; % c, for self-avoiding loop in 3D embedded in a chain, standard literature value (when DNA is not confined)
    
    % assign memory
    tmpConditionalProbsFactor = zeros(seqLen - 1,1);        
    a = zeros(seqLen - 2,1);
    a_old = zeros(seqLen - 2,1);
    probsNonmelted = zeros(seqLen,1);
    mu = zeros(seqLen - 1,1);
    mu_old = zeros(seqLen - 1,1);

    % NOTE: below the arguments in tmpConditionalProbsFactor, a, probsNonmelted, and mu
    % are shifted by one, due to the Matlab one-indexing

    % -- Determine conditional probability [proportional to T_k] --
    % Initialize
    tmpConditionalProbsFactor(seqLen - 1) = seqWeightsHydrogenBonds(seqLen - 2) * seqWeightsStackingInteraction(seqLen - 2);
    % Iterate
    for bpIdxK = (seqLen - 3):-1:1
       a(2) = ringFactor * seqWeightsStackingInteraction(bpIdxK + 2) * tmpConditionalProbsFactor(bpIdxK + 2); 
       for bpIdxJ = 2:(seqLen - 2 - bpIdxK)
          a(bpIdxJ + 1) = (bpIdxJ^(-loopExponentC)) * tmpConditionalProbsFactor(bpIdxK + 2) * a_old(bpIdxJ)/((bpIdxJ-1)^(-loopExponentC));
       end
       tmpConditionalProbsFactor(bpIdxK + 1) = seqWeightsHydrogenBonds(bpIdxK) * seqWeightsStackingInteraction(bpIdxK)/(1 + sum(a(2:(seqLen - 1 - bpIdxK))));
       a_old = a;
    end
    a(2) = ringFactor * seqWeightsStackingInteraction(2) * tmpConditionalProbsFactor(2);
    for bpIdxJ = 2:(seqLen - 2)
       a(bpIdxJ + 1) = (bpIdxJ^(-loopExponentC)) * tmpConditionalProbsFactor(2) * a_old(bpIdxJ)/((bpIdxJ-1)^(-loopExponentC));
    end
    tmpConditionalProbsFactor(1) = 1/(1 + sum(a(2:seqLen - 1)));


    % -- Determine unconditional probability  --- 
    % -- that bp k ( = 0,1,...,M + 1) is closed   ---

    % Initialize
    probsNonmelted(1) = 1;
    probsNonmelted(2) = tmpConditionalProbsFactor(1);
    % Iterate
    for bpIdxK = 1:(seqLen - 2)
       if bpIdxK == 1 
          mu(bpIdxK) = ringFactor * seqWeightsStackingInteraction(2) * tmpConditionalProbsFactor(1) * tmpConditionalProbsFactor(2);
       else % bpIdxK >= 2
          mu(bpIdxK) = ringFactor * tmpConditionalProbsFactor(bpIdxK) * tmpConditionalProbsFactor(bpIdxK + 1) * seqWeightsStackingInteraction(bpIdxK + 1)/(seqWeightsHydrogenBonds(bpIdxK-1) * seqWeightsStackingInteraction(bpIdxK-1));
       end
       for bpIdxJ = 0:(bpIdxK - 2)
          mu(bpIdxJ + 1) = ((bpIdxK - bpIdxJ)^(-loopExponentC)) * tmpConditionalProbsFactor(bpIdxK + 1) * mu_old(bpIdxJ + 1) * seqWeightsStackingInteraction(bpIdxK + 1)/(seqWeightsStackingInteraction(bpIdxK) * ((bpIdxK - bpIdxJ - 1)^(-loopExponentC)));
       end
       tmpConditionalProbs = tmpConditionalProbsFactor(bpIdxK + 1)/(seqWeightsHydrogenBonds(bpIdxK) * seqWeightsStackingInteraction(bpIdxK));
       probsNonmelted(bpIdxK + 2) = probsNonmelted(bpIdxK + 1) * tmpConditionalProbs + sum((mu(1:bpIdxK) .* probsNonmelted(1:bpIdxK))); 
       mu_old = mu;
    end

    % We should have probsNonmelted(end) = 1
end