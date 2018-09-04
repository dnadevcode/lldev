function [nrmVectCenterOfMass] = calc_nrm_vect_center_of_mass(massVect)
    % CALC_NRM_VECT_CENTER_OF_MASS
    %
    % Inputs:
    %   massVect
    %
    % Outputs:
    %   centerOfMass
    %
    % Authors:
    %   Saair Quaderi (refactoring, simplification)
    %   Charleston Noble (old version)

    massVect = massVect(:);
    vectLen = length(massVect);

    % Center of mass calculation normalized between 0 and 1
    % Note from Saair: previously pts was effectively
    % = (1:vectLen)/vectLen
    % = linspace(1/vectLen, 1, vectLen)
    % but that seems wrong
    pts = linspace(0, 1, vectLen)'; 
    nrmVectCenterOfMass = sum(pts .* massVect)/sum(massVect);
end