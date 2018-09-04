function [moleculeStartEdgeIdxs, moleculeEndEdgeIdxs, mainKymoMoleculeMask] = approx_main_kymo_molecule_edges(kymo, edgeDetectionSettings)
    % APPROX_MAIN_KYMO_MOLECULE_EDGES - Attempts to find the start and
    %  end indices for the main molecule in the kymograph
    %
    % For more details see:
    %  See basic_otsu_approx_main_kymo_molecule_edges
    %  See adjust_kymo_edge_detection
    %
    % Inputs:
    %   kymo
    %   kymoEdgeDetectionSettings
    %   
    % Outputs:
    %   moleculeStartEdgeIdxsApprox
    %   moleculeEndEdgeIdxsApprox
    %   mainKymoMoleculeMaskApprox
    %
    % Authors:
    %   Saair Quaderi
    %     (refactoring)
    %   Charleston Noble
    %     (original version, algorithm)
    

    otsuApproxSettings = edgeDetectionSettings.otsuApproxSettings;
    import OptMap.MoleculeDetection.EdgeDetection.basic_otsu_approx_main_kymo_molecule_edges;
    [moleculeStartEdgeIdxsFirstApprox, moleculeEndEdgeIdxsFirstApprox, mainKymoMoleculeMaskFirstApprox] = basic_otsu_approx_main_kymo_molecule_edges(...
        kymo, ...
        otsuApproxSettings.globalThreshTF, ...
        otsuApproxSettings.smoothingWindowLen, ...
        otsuApproxSettings.imcloseHalfGapLen, ...
        otsuApproxSettings.numThresholds, ...
        otsuApproxSettings.minNumThresholdsFgShouldPass ...
    );

    
    if (all(isnan(moleculeStartEdgeIdxsFirstApprox)) || all(isnan(moleculeEndEdgeIdxsFirstApprox)))
        error('Edge detections missing');
    elseif (any(isnan(moleculeStartEdgeIdxsFirstApprox)) || any(isnan(moleculeEndEdgeIdxsFirstApprox)))
        import OptMap.KymoAlignment.nearest_nonnan;
        moleculeStartEdgeIdxsFirstApprox = floor(nearest_nonnan(moleculeStartEdgeIdxsFirstApprox));
        moleculeEndEdgeIdxsFirstApprox = ceil(nearest_nonnan(moleculeStartEdgeIdxsFirstApprox));
        % warning('Missing edge detections filled in');
    end
    
    
    if edgeDetectionSettings.skipDoubleTanhAdjustment
        moleculeStartEdgeIdxs = moleculeStartEdgeIdxsFirstApprox;
        moleculeEndEdgeIdxs = moleculeEndEdgeIdxsFirstApprox;
        mainKymoMoleculeMask = mainKymoMoleculeMaskFirstApprox;
    else
        import OptMap.MoleculeDetection.EdgeDetection.DoubleTanh.adjust_kymo_edge_detection;
        tanhSettings = edgeDetectionSettings.tanhSettings;
        [moleculeStartEdgeIdxs, moleculeEndEdgeIdxs, mainKymoMoleculeMask] = adjust_kymo_edge_detection(...
            kymo, ...
            moleculeStartEdgeIdxsFirstApprox, ...
            moleculeEndEdgeIdxsFirstApprox, ...
            tanhSettings ...
        );
    end
end