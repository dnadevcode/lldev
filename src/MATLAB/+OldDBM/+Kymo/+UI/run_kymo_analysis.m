function [kymoStatsTable] = run_kymo_analysis(dbmODW, skipDoubleTanhAdjustment)
    % RUN_KYMO_ANALYSIS - calculates the lengths of the molecules using
    %	the method chosen by the user
    %
    % Inputs:
    %   dbmODW
    %   skipDoubleTanhAdjustment
    %
    % Authors:
    %   Saair Quaderi (Refactoring)
    %   Charleston Noble

    import OldDBM.Kymo.Core.run_raw_kymos_edge_detection;

    [ ...
        kymosMoleculeLeftEdgeIdxs, ...
        kymosMoleculeRightEdgeIdxs, ...
        moleculeMasks, ...
        rawKymos, ...
        rawKymoFileIdxs, ...
        rawKymoFileMoleculeIdxs ...
        ] = run_raw_kymos_edge_detection(dbmODW, skipDoubleTanhAdjustment);

    numMolecules = length(rawKymoFileMoleculeIdxs);

    if numMolecules == 0
        disp('There were no raw kymos to find molecule edges in');
        return;
    end


    kymoStatsStructs = cell(numMolecules, 1);
    import OldDBM.Kymo.Core.calc_kymo_stats;
    for moleculeNum=1:numMolecules
        rawKymoFileIdx = rawKymoFileIdxs(moleculeNum);
        rawKymoFileMoleculeIdx = rawKymoFileMoleculeIdxs(moleculeNum);
        srcFilename = dbmODW.get_molecule_src_filename(rawKymoFileIdx);
        fprintf('Finding edges for molecule %d in %s\n', rawKymoFileMoleculeIdx, srcFilename);

        rawKymo = rawKymos{moleculeNum};
        moleculeMask = moleculeMasks{moleculeNum};
        moleculeLeftEdgeIdxs = kymosMoleculeLeftEdgeIdxs{moleculeNum};
        moleculeRightEdgeIdxs = kymosMoleculeRightEdgeIdxs{moleculeNum};

        kymoStatsStruct = calc_kymo_stats(rawKymo, moleculeMask, moleculeLeftEdgeIdxs, moleculeRightEdgeIdxs);

        % meanMainMoleculePixelIntensity = mean(rawKymo(mainKymoMoleculeMask));
        meanNonMainMoleculePixelIntensity = mean(rawKymo(~moleculeMask));
        kymoStatsStruct.meanNonMainMoleculePixelIntensity = meanNonMainMoleculePixelIntensity;

        kymoStatsStruct.srcFilename = srcFilename;
        kymoStatsStruct.fileIdx = rawKymoFileIdx;
        kymoStatsStruct.fileMoleculeIdx = rawKymoFileMoleculeIdx;
        kymoStatsStructs{moleculeNum} = kymoStatsStruct;
    end

    kymoStatsStructs = vertcat(kymoStatsStructs{:});
    structFields = fieldnames(kymoStatsStructs);
    [~, idxsFirst] = intersect(structFields, {'srcFilename', 'fileIdx', 'fileMoleculeIdx'});
    fieldReordering = [idxsFirst(:); setdiff((1:numel(structFields))', idxsFirst(:))];
    kymoStatsStructs = orderfields(kymoStatsStructs, fieldReordering);
    kymoStatsTable = struct2table(kymoStatsStructs, 'AsArray', true);


    import OldDBM.Kymo.UI.disp_intensity_drop_warnings;
    disp_intensity_drop_warnings(dbmODW, rawKymoFileIdxs, rawKymoFileMoleculeIdxs, rawKymos, moleculeMasks, kymoStatsStructs);

    disp('Molecule Stats:');
    disp(kymoStatsTable);

    % useMedianNotMeanForLengthStats = skipDoubleTanhAdjustment;
    % DBM_Gui.update_molecules_stats(dbmODW, kymoStatsTable, useMedianNotMeanForLengthStats);
end