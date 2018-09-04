function [probsNonmelted] = calculate_nonmelting_probs(ntSeqStr, temperature_Celsius, saltConc_molar, ringFactor)
    % CALCULATE_NONMELTING_PROBS
    %
    % Calculates the equilibrium probability that bps are not melted,
    %  with the Fixman-Freire approximation for the Poland model
    %  uses the Frank-Kamenetskii stability data with the assumption that
    %  the first and last of the bps are clamped together
    %
    % [A. Krueger, E. Protozanova and M. Frank-Kamenetskii, Biophys J. 90, 3091 (2006), Table 1] 
    %
    %
    % Inputs:
    %  ntSeqStr
    %    the 5'-3' DNA sequence of As, Cs, Ts, and Gs
    %  temperature_Celsius
    %    the temperature in Celsius
    %  saltConc_molar
    %    the salt concentration as a quantity in molar
    %  ringFactor (optional, defaults to 1e-3)
    %     bubble initiation ring factor parameter
    %
    % Authors:
    %  Saair Quaderi (Converted from Java "fixmanFreireCalculator" to Matlab)
    %  Charleston Noble (?) (Converted from C version to Java version)
    %  Michaela Reiter-Schad (?) (C version)
    
    import MMT.Core.calculate_breaking_weights;
    import MMT.Core.retrieve_fixman_freire_coefficients;
    
    if isempty(ntSeqStr)
        probsNonmelted = NaN(0,1);
        return;
    else
        validateattributes(ntSeqStr, {'char'}, {'row', 'vector'}, 1);
    end
    
    if nargin < 4
        ringFactor = 1e-3; % from Frank-Kamenetskii
    end
    
    % TODO: Adjust temperature because of formamide which
    %  lowers DNA melting temperatures
    % (found this related commented line elsewhere in the codebase)
    % % temperature_Celsius = temperature_Celsius + 0.62*formamide;
    
    ABS_ZERO_IN_CELSIUS = -273.15; %  subtract from Celsius for Kelvin, add to Kelvin for Celsius
    validateattributes(temperature_Celsius, {'numeric'}, {'scalar', 'finite', '>', ABS_ZERO_IN_CELSIUS}, 2);
    temperature_Kelvin = temperature_Celsius - ABS_ZERO_IN_CELSIUS;
    validateattributes(saltConc_molar, {'numeric'}, {'scalar', 'positive', 'finite'}, 3);
    ntIntSeq = nt2int(ntSeqStr);
    if any(ntIntSeq < 1) || any(ntIntSeq > 4)
        error('Gaps, unknown nucleotides, and ambiguous nucleotides are not supported by this program');
    end
    seqLen = length(ntIntSeq);
    
    %   u_hbW_aTaS
    %     the weights associated with breaking the hydrogen bonds between
    %      basepairs A & T (W = relatively Weak)
    %      at the temperature and salt concentration provided
    %   u_hbS_aTaS
    %     the weights associated with breaking the hydrogen bonds between 
    %      basepairs C & G (S = relatively Strong)
    %      at the temperature and salt concentration provided
    %   mat_u_st_ACGT_aTaS
    %     the statistical weights for breaking the stacking interactions 
    %     between a 5'-N-3' basepair and the subsequent 5'-N-3' basepair
    %     in a 4x4 matrix where the row index is associated with the first
    %     basepair and the column index is associated with the second
    %     basepair and indices represent basepairs
    %     (1 = A, 2 = C, 3 = G, 4 = T)
    %     at the temperature and salt concentration provided)
    [u_hbW_aTaS, u_hbS_aTaS, mat_u_st_ACGT_aTaS] = calculate_breaking_weights(temperature_Kelvin, saltConc_molar);
    
    % -- Assign statistical weights based on sequence --

    % DNA sequence based hydrogen bonds (NaNing assumed-to-be-clamped start and end bps)
    u_hb_vect_ACGT = [...
            u_hbW_aTaS; ... % for 5'-A-3' (Weak)
            u_hbS_aTaS; ... % for 5'-C-3' (Strong)
            u_hbS_aTaS; ... % for 5'-G-3' (Strong)
            u_hbW_aTaS ...  % for 5'-T-3' (Weak)
        ];
    seqWeightsHydrogenBonds = u_hb_vect_ACGT(ntIntSeq);
    seqWeightsHydrogenBonds([1, end]) = NaN;
    
    % DNA sequence k-mer (k = 2) based stacking parameters
    seqWeightsStackingInteraction = mat_u_st_ACGT_aTaS(sub2ind([4, 4], ntIntSeq(1:(end - 1)), ntIntSeq(2:end)));
    seqWeightsStackingInteraction = [seqWeightsStackingInteraction(:); NaN]; % a.k.a. u_st
    
    [ffCoeffVectA, ffCoeffVectB] = retrieve_fixman_freire_coefficients();
    %[ffCoeffVectA, ffCoeffVectB] = MMT.FixmanFreire.calc_fixman_freire_coeffs;
    expNegVectB = exp(-ffCoeffVectB);
    
    % Compute the probability that the bp (bpIdx, ..., bpIdx + gammap - 1)
    %  are closed using the Poland algorithm

    abLen = length(ffCoeffVectB);
    tmpVectS = zeros(abLen, 1);

    tmpConditionalProbs = NaN(seqLen, 1);
    probsNonmelted = NaN(seqLen, 1);

    % Determine conditional probability
    % (proportional to temperature in Kelvin)

    tmpConditionalProbs(seqLen - 1) = 1;
    
    for bpIdx = (seqLen - 2):-1:1
        tmpVectS = tmpConditionalProbs(bpIdx + 1) * seqWeightsHydrogenBonds(bpIdx + 1) * seqWeightsStackingInteraction(bpIdx) * expNegVectB .* (ringFactor * seqWeightsStackingInteraction(bpIdx + 1) + tmpVectS);
        tmpConditionalProbs(bpIdx) = 1.0 / (1.0 + sum(ffCoeffVectA.*tmpVectS));
    end
   % figure,plot(tmpConditionalProbs)
    % Determine unconditional probability that bp is closed/not melted
    probsNonmelted(1) = 1;
    probsNonmelted(2) = tmpConditionalProbs(1);

    tmpVectA = zeros(abLen, 1);
    for bpIdx = 3:seqLen
        tmpVectA = tmpConditionalProbs(bpIdx - 1) * seqWeightsHydrogenBonds(bpIdx - 1) * seqWeightsStackingInteraction(bpIdx - 1) * expNegVectB .* (ringFactor * seqWeightsStackingInteraction(bpIdx - 2) * probsNonmelted(bpIdx - 2) * tmpConditionalProbs(bpIdx - 2) + tmpVectA);
        probsNonmelted(bpIdx) = probsNonmelted(bpIdx - 1) * tmpConditionalProbs(bpIdx - 1) + sum(ffCoeffVectA.*tmpVectA);
    end
    
end