function [u_hbW_aTaS, u_hbS_aTaS, mat_u_st_ACGT_aTaS] = calculate_breaking_weights(temperature_Kelvin, saltConc_molar)
    % CALCULATE_BREAKING_WEIGHTS - calculates breaking weights related to
    %  DNA melting
    %
    % Stacking interaction free energy between basepairs in a bp-dimer
    %   (based on DOI: 10.1529/biophysj.105.078774)
    %
    % Inputs:
    %  temperature_Kelvin
    %    the temperature in Kelvin
    %  saltConc_molar
    %    the salt concentration as a quantity in molar
    % 
    % Outputs:
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
    %
    % For more information see papers below:
    %
    % DOI: 10.1529/biophysj.105.078774
    %  http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1432109/
    %  Biophys J. 2006 May 1; 90(9): 3091�3099.
    %  Sequence-Dependent Basepair Opening in DNA Double Helix
    %  Andrew Krueger, Ekaterina Protozanova, and Maxim D. Frank-Kamenetskii
    %
    % DOI: 10.1016/j.jmb.2004.07.075
    %  http://www.ncbi.nlm.nih.gov/pubmed/15342236
    %  J Mol Biol. 2004 Sep 17;342(3):775-85.
    %  Stacked�Unstacked Equilibrium at the Nick Site of DNA
    %  Ekaterina Protozanova, Peter Yakovchuk, Maxim D. Frank-Kamenetskii
    %
    % Authors:
    %  Saair Quaderi (Converted from Java "fixmanFreireCalculator" to Matlab)
    %  Charleston Noble (?) (Converted from C version to Java version)
    %  Michaela Reiter-Schad (?) (C version)
    
    
    
    
    validateattributes(temperature_Kelvin, {'numeric'}, {'scalar', 'positive', 'finite'}, 1);
    validateattributes(saltConc_molar, {'numeric'}, {'scalar', 'positive', 'finite'}, 2);
    
    refTemperature_Kelvin = 37 + 273.15; % reference temperature, in Kelvin (37 in Celsius)
    temperatureDiff_Kelvin = temperature_Kelvin - refTemperature_Kelvin;
    temperatureAdjustmentAddend = 0.0260 * temperatureDiff_Kelvin; % temperature dep. of stacking
    
    refSaltConc_molar = 0.1; % reference salt concentration (NaCl), in molar
    saltConcRatioVsRef = saltConc_molar/refSaltConc_molar;
    logOfSaltConcRatioVsRef = log(saltConcRatioVsRef);
    saltConcAdjustmentAddend = -0.205 * logOfSaltConcRatioVsRef;
    
    adjustmentAddend = saltConcAdjustmentAddend + temperatureAdjustmentAddend;
    
    % Compute statistical weights -----------------------
    
    % --- Calculates the free energy per stack --------------

    
    % Note on abbreviations:
    %   DeltaG = change in Gibb's free energy
    %   rT = using reference temperature
    %   aT = adjusted to actual provided temperature
    %   rS = using reference salt concentration
    %   aS = adjusted to actual provided salt concentration
    
    % kcal/mol, with reference temperature and salt concentration
    %  (using ACGT column & row ordering)
    
    
    % DOI: 10.1529/biophysj.105.078774
    % (Table 1) stacking and basepairing parameters
    % % Reference values with reference temperature (37 C) and salt concentration (0.1 M)
    
    matDeltaG_ACGT_rTrS = [...
        [-1.49, -2.19, -1.44, -1.72];... % [AA, AC, AG, AT] - row values in column 1 (A_)
        [-0.93, -1.82, -1.29, -1.44];... % [CA, CC, CG, CT] - row values in column 2 (C_)
        [-1.81, -2.55, -1.82, -2.19];... % [GA, GC, GG, GT] - row values in column 3 (G_)
        [-0.57, -1.81, -0.93, -1.49]...  % [TA, TC, TG, TT] - row values in column 4 (T_)
    ];

%     % Note:
%     %  sequences are 5'-__-3' and there reverse complements in 3'-__-5'
%     %  must have equivalent values
%    
%     % validate equality for reverse complements:
%     if not(isequal(flipud(matDeltaG_ACGT_rTrS), flipud(matDeltaG_ACGT_rTrS)'))
%         error('Value associated with 2-bp sequence and its reverse complement must be equal');
%     end
    
    
%     deltaG_bp_hbW_rTrS = 0.64; % kcal/mol, for AT 
%     deltaG_bp_hbS_rTrS = 0.12; % kcal/mol, for CG


%     matDeltaG_ACGT_rTrS = matDeltaG_ACGT_rTrS - 0.01; % Saair: Why???
%     deltaG_bp_hbW_rTrS = deltaG_bp_hbW_rTrS + 0.01; % Saair: Why???
%     deltaG_bp_hbS_rTrS = deltaG_bp_hbS_rTrS + 0.01; % Saair: Why???
    


   % switch from ACGT column & row ordering to ATGC ordering
    matDeltaG_ACGT_aTaS = matDeltaG_ACGT_rTrS + adjustmentAddend; % kcal/mol, adjusted for temperature and salt concentration change
    
    
    KCAL_IN_JOULES = 4186.8; 
    MOLAR_GAS_CONSTANT_JoulesPerMoleKelvin = 8.31451; % molar gas constant (in units J/(mol*K))
    MOLAR_GAS_CONSTANT_KcalsPerMoleKelvin = MOLAR_GAS_CONSTANT_JoulesPerMoleKelvin/KCAL_IN_JOULES; % molar gas constant (in units kcal/(mol*K))
    kcalsPerMoleAtTemperature = MOLAR_GAS_CONSTANT_KcalsPerMoleKelvin * temperature_Kelvin;
    molarPerKcalAtTemperature = 1.0 / kcalsPerMoleAtTemperature;
    
    % Stacking statistical weights
    mat_u_st_ACGT_aTaS = exp(molarPerKcalAtTemperature .* matDeltaG_ACGT_aTaS);
    


    % DOI: 10.1529/biophysj.105.078774
    %  Equation (2)
    lnSaltConc = log(saltConc_molar);
    % melting temperatures characterizing DNA stability
    meltingTemperature_hbW_Kelvin_aS = 355.55 + (7.95 * lnSaltConc); % empirical formula for AT
    meltingTemperature_hbS_Kelvin_aS = 391.55 + (4.89 * lnSaltConc); % empirical formula for CG

    
    % DOI: 10.1529/biophysj.105.078774
    %  Equation (3)
    % free-energy difference stability parameters
    % deltaS = deltaG per difference in temperature from reference temperature in degrees (Kelvin/Celsius) 
    deltaSMeltingTemperature_rTrS = -24.85E-3; % (kcal/mol)/Kelvin with reference temperature and salt concentration
    deltaG_base_W_aTaS = deltaSMeltingTemperature_rTrS * (meltingTemperature_hbW_Kelvin_aS - temperature_Kelvin); % kcal/mol
    deltaG_base_S_aTaS = deltaSMeltingTemperature_rTrS * (meltingTemperature_hbS_Kelvin_aS - temperature_Kelvin); % kcal/mol
    
    
    % DOI: 10.1529/biophysj.105.078774
    %  Equation (1)
    deltaG_bp_hbW_aTaS = deltaG_base_W_aTaS - mean2(matDeltaG_ACGT_aTaS([1, 4], [1, 4])); % AA, AT, TA, TT
    deltaG_bp_hbS_aTaS = deltaG_base_S_aTaS - mean2(matDeltaG_ACGT_aTaS([2, 3], [2, 3])); % CC, CG, GC, GG
    
    % Hydrogen bond energies
    u_hbW_aTaS = exp(molarPerKcalAtTemperature * deltaG_bp_hbW_aTaS);
    u_hbS_aTaS = exp(molarPerKcalAtTemperature * deltaG_bp_hbS_aTaS);
end