function [centerOfMassTable] = calc_raw_kymos_centers_of_mass(dbmODW)
    % CALC_RAW_KYMOS_CENTERS_OF_MASS - calculates the horizontal center
    %    of mass (actually foreground intensity) of the existing raw
    %    kymographs
    %
    % Inputs:
    %   dbmODW
    %
    % Outputs:
    %  centerOfMassTable
    %
    %
    % Authors:
    %  Saair Quaderi (complete refactoring)
    %  Charleston Noble (previous version of functionality)
    %


    % TODO: figure out who needs this information and why?

    import OldDBM.Kymo.Core.calc_nrm_vect_center_of_mass;
    import OptMap.MoleculeDetection.approx_fg_mask_using_otsu;

    [rawKymos, rawKymoFileIdxs, rawKymoFileMoleculeIdxs] = dbmODW.get_all_existing_raw_kymos();
    srcFilenames = dbmODW.get_molecule_src_filenames(rawKymoFileIdxs);
    numThresholds = 2;
    minNumThresholdsFgShouldPass = 1;
    rawKymoFgMasks = cellfun(@(rawKymo) approx_fg_mask_using_otsu(rawKymo, numThresholds, minNumThresholdsFgShouldPass), rawKymos, 'UniformOutput', false);

    centersOfMassHoriz = cellfun(@(rawKymo, rawKymoFgMask) calc_nrm_vect_center_of_mass(sum(rawKymo.*rawKymoFgMask, 1)), rawKymos, rawKymoFgMasks);

    % arrayfun(@(fileIdx, matCenterOfMassHoriz) set_movie_file_center_of_mass_horiz(fileIdx, matCenterOfMassHoriz), fileIdxs, centersOfMassHoriz);

    centerOfMassTableColVals = {srcFilenames; num2cell(rawKymoFileIdxs); num2cell(rawKymoFileMoleculeIdxs); num2cell(centersOfMassHoriz)};
    centerOfMassTableColNames = {'Source Filename'; 'File Number'; 'File Molecule Number'; 'Center of Mass (Horizontal)'};
    centerOfMassTableValidVarNames = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(centerOfMassTableColNames));
    centerOfMassTable = table(centerOfMassTableColVals{:}, 'VariableNames', centerOfMassTableValidVarNames);
end