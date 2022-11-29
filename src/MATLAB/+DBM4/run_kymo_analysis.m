function [kymoStatsTable] = run_kymo_analysis(kymoCells,skipEdgeDetection)
    % RUN_KYMO_ANALYSIS - calculates the lengths of the molecules using
    %	the method chosen by the user
    %
    % Inputs:
    %   dbmODW
    %   skipDoubleTanhAdjustment
    %

    if nargin < 2
        skipEdgeDetection = false;
    end
    
    rawKymos = kymoCells.rawKymos;
    rawKymoFileIdxs = kymoCells.rawKymoFileIdxs;
    rawKymoFileMoleculeIdxs = kymoCells.rawKymoFileMoleculeIdxs;

    kymosMoleculeLeftEdgeIdxs = cell(1,length(rawKymos));
    kymosMoleculeRightEdgeIdxs = cell(1,length(rawKymos));
    moleculeMasks = cell(1,length(rawKymos));

    if skipEdgeDetection
       kymosMoleculeLeftEdgeIdxs = kymoCells.kymosMoleculeLeftEdgeIdxs;
       kymosMoleculeRightEdgeIdxs = kymoCells.kymosMoleculeRightEdgeIdxs;
       moleculeMasks = kymoCells.rawBitmask';
    else
%         import OldDBM.Kymo.Core.run_raw_kymos_edge_detection;
% 
%         [ ...
%             kymosMoleculeLeftEdgeIdxs, ...
%             kymosMoleculeRightEdgeIdxs, ...
%             moleculeMasks, ...
%             rawKymos, ...
%             rawKymoFileIdxs, ...
%             rawKymoFileMoleculeIdxs ...
%             ] = run_raw_kymos_edge_detection(dbmODW, skipDoubleTanhAdjustment);
    end
    numMolecules = length(rawKymoFileMoleculeIdxs);

    if numMolecules == 0
        disp('There were no raw kymos to find molecule edges in');
        return;
    end


    kymoStatsStructs = cell(numMolecules, 1);
    import OldDBM.Kymo.Core.calc_kymo_stats;
    for moleculeNum=1:numMolecules
        srcFilename = kymoCells.rawKymoName{moleculeNum};
        fprintf('Finding edges for molecule %d in %s\n', moleculeNum, srcFilename);

        rawKymo = rawKymos{moleculeNum};
        moleculeMask = moleculeMasks{moleculeNum};
        moleculeLeftEdgeIdxs = kymosMoleculeLeftEdgeIdxs{moleculeNum};
        moleculeRightEdgeIdxs = kymosMoleculeRightEdgeIdxs{moleculeNum};

        kymoStatsStruct = calc_kymo_stats(rawKymo, moleculeMask, moleculeLeftEdgeIdxs', moleculeRightEdgeIdxs');

        % meanMainMoleculePixelIntensity = mean(rawKymo(mainKymoMoleculeMask));
        meanNonMainMoleculePixelIntensity = mean(rawKymo(~moleculeMask));
        kymoStatsStruct.meanNonMainMoleculePixelIntensity = meanNonMainMoleculePixelIntensity;

        kymoStatsStruct.srcFilename = srcFilename;
        kymoStatsStruct.fileIdx = rawKymoFileIdxs(moleculeNum);
        kymoStatsStruct.fileMoleculeIdx = rawKymoFileMoleculeIdxs(moleculeNum);
        kymoStatsStructs{moleculeNum} = kymoStatsStruct;
    end

    kymoStatsStructs = vertcat(kymoStatsStructs{:});
    structFields = fieldnames(kymoStatsStructs);
    [~, idxsFirst] = intersect(structFields, {'srcFilename', 'fileIdx', 'fileMoleculeIdx'});
    fieldReordering = [idxsFirst(:); setdiff((1:numel(structFields))', idxsFirst(:))];
    kymoStatsStructs = orderfields(kymoStatsStructs, fieldReordering);
    kymoStatsTable = struct2table(kymoStatsStructs, 'AsArray', true);


    import DBM4.disp_intensity_drop_warnings;
    DBM4.disp_intensity_drop_warnings(kymoCells.rawKymoName,rawKymoFileIdxs, rawKymoFileMoleculeIdxs, rawKymos, moleculeMasks, kymoStatsStructs);

    disp('Molecule Stats:');
    disp(kymoStatsTable);

    % useMedianNotMeanForLengthStats = skipDoubleTanhAdjustment;
    % DBM_Gui.update_molecules_stats(dbmODW, kymoStatsTable, useMedianNotMeanForLengthStats);
end