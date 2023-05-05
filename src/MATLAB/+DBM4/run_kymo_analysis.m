function [kymoStatsTable,moleculeMasks] = run_kymo_analysis(kymoCells,sets)
    % RUN_KYMO_ANALYSIS - calculates the lengths of the molecules using
    %	the method chosen by the user
    %
    % Inputs:
    %   dbmODW
    %   skipDoubleTanhAdjustment
    %

    if nargin < 2
        sets.skipEdgeDetection = false;
    end
    
    rawKymos = kymoCells.rawKymos; % should be aligned raw kymos

    if isfield(kymoCells,'rawKymoFileIdxs')
        rawKymoFileIdxs = kymoCells.rawKymoFileIdxs;
    else
        rawKymoFileIdxs = 1:length(rawKymos);
    end

    if isfield(kymoCells,'rawKymoFileMoleculeIdxs')
        rawKymoFileMoleculeIdxs = kymoCells.rawKymoFileMoleculeIdxs;
    else
        rawKymoFileMoleculeIdxs = 1:length(rawKymos);
    end
    
    import DBM4.run_raw_kymos_edge_detection;
    if sets.skipEdgeDetection
        if isfield(kymoCells,'kymosMoleculeLeftEdgeIdxs')
           kymosMoleculeLeftEdgeIdxs = kymoCells.kymosMoleculeLeftEdgeIdxs;
           kymosMoleculeRightEdgeIdxs = kymoCells.kymosMoleculeRightEdgeIdxs;
        else
            kymosMoleculeLeftEdgeIdxs = cellfun(@(y) arrayfun(@(x) find(y(x,:) >0,1,'first'),1:size(y,1)),kymoCells.rawBitmask,'un',false);
            kymosMoleculeRightEdgeIdxs =  cellfun(@(y) arrayfun(@(x) find(y(x,:) >0,1,'last')',1:size(y,1)),kymoCells.rawBitmask,'un',false);
        end
       moleculeMasks = kymoCells.rawBitmask';
    else
        [ ...
            kymosMoleculeLeftEdgeIdxs, ...
            kymosMoleculeRightEdgeIdxs, ...
            moleculeMasks, ....
            ] = run_raw_kymos_edge_detection(rawKymos, sets);
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
        meanNonMainMoleculePixelIntensity = nanmean(rawKymo(~moleculeMask));
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