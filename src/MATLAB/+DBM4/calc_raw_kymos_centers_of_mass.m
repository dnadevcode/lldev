function [centerOfMassTable] = calc_raw_kymos_centers_of_mass(kymoCells,sets)
    % CALC_RAW_KYMOS_CENTERS_OF_MASS - calculates the horizontal center
    %    of mass (actually foreground intensity) of the existing raw
    %    kymographs
    %
    %

    %   Args:
    % 
    %       kymoCells
    %
    %   Returns:
    %       centerOfMassTable

    if nargin < 2
        numThresholds = 2;
        minNumThresholdsFgShouldPass = 1;
    end
    
    rawKymos = kymoCells.rawKymos; % should be aligned raw kymos
    rawBitmasks = kymoCells.rawBitmask; % should be aligned raw kymos

    rawKymoFileIdxs = kymoCells.rawKymoFileIdxs;
    rawKymoFileMoleculeIdxs = kymoCells.rawKymoFileMoleculeIdxs;
    srcFilenames = kymoCells.rawKymoName;



    % TODO: figure out who needs this information and why?

    import OldDBM.Kymo.Core.calc_nrm_vect_center_of_mass;
    import OptMap.MoleculeDetection.approx_fg_mask_using_otsu;

%     rawKymoFgMasks = cellfun(@(rawKymo) approx_fg_mask_using_otsu(rawKymo, numThresholds, minNumThresholdsFgShouldPass), rawKymos, 'UniformOutput', false);

    centersOfMassHoriz = cellfun(@(rawKymo, rawKymoFgMask) calc_nrm_vect_center_of_mass(nansum(rawKymo.*rawKymoFgMask, 1)), rawKymos, rawBitmasks);

    % arrayfun(@(fileIdx, matCenterOfMassHoriz) set_movie_file_center_of_mass_horiz(fileIdx, matCenterOfMassHoriz), fileIdxs, centersOfMassHoriz);

    centerOfMassTableColVals = {srcFilenames; num2cell(rawKymoFileIdxs); num2cell(rawKymoFileMoleculeIdxs); num2cell(centersOfMassHoriz)};
    centerOfMassTableColNames = {'Source Filename'; 'File Number'; 'File Molecule Number'; 'Center of Mass (Horizontal)'};
    centerOfMassTableValidVarNames = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(centerOfMassTableColNames));
    centerOfMassTable = table(centerOfMassTableColVals{:}, 'VariableNames', centerOfMassTableValidVarNames);
end