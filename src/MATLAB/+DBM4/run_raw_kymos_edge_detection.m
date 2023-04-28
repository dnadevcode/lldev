function [kymosMoleculeLeftEdgeIdxs, kymosMoleculeRightEdgeIdxs, kymosMoleculeMask] =...
    run_raw_kymos_edge_detection(rawKymos, sets)
    
    numMolecules = length(rawKymos); % number of molecules
    
    import OptMap.MoleculeDetection.EdgeDetection.get_default_edge_detection_settings; % default settings (if not already in sets/
    if ~isfield(sets,'edgeDetectionSettings')
        sets.edgeDetectionSettings = get_default_edge_detection_settings(~sets.double_tanh_edge_detection);
    end
    
    kymosMoleculeLeftEdgeIdxs = cell(1,numMolecules);    
    kymosMoleculeRightEdgeIdxs = cell(1,numMolecules);
    kymosMoleculeMask = cell(1,numMolecules);


    import OptMap.MoleculeDetection.EdgeDetection.approx_main_kymo_molecule_edges;
    for moleculeNum = 1:numMolecules
        fprintf('Finding edges for molecule %d \n', moleculeNum);
        rawKymo = rawKymos{moleculeNum};

        [kymoMoleculeLeftEdgeIdxs, kymoMoleculeRightEdgeIdxs, kymoMoleculeMask] = approx_main_kymo_molecule_edges(rawKymo, sets.edgeDetectionSettings);
        kymosMoleculeLeftEdgeIdxs{moleculeNum} = kymoMoleculeLeftEdgeIdxs';
        kymosMoleculeRightEdgeIdxs{moleculeNum} = kymoMoleculeRightEdgeIdxs';
        kymosMoleculeMask{moleculeNum} = kymoMoleculeMask;
    end
end