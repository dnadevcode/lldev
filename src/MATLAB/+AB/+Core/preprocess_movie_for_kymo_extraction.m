function [kymoMolEdgeIdxs, movieRot, rRot, cRot, ccIdxs, ccStructNoEdgeAdj, rotationAngle] = preprocess_movie_for_kymo_extraction(movieIn, preprocessSettings)

    
    % ------
    
    fprintf('Detecting rotation angle\n');
    tic
    
    import AB.Core.get_rotation_angle;
    [rotationAngle] = get_rotation_angle(movieIn, preprocessSettings.rotation);
    
    toc
    fprintf('Detected rotation angle\n');
    
    % ------
    

    fprintf('Rotating movie\n');
    tic
    
    import AB.Core.rotate_movie;
    [movieRot, rRot, cRot, segmentFrameRot] = rotate_movie(movieIn, rotationAngle);
    movieRot(repmat(~segmentFrameRot, [1, 1, size(movieRot, 3), size(movieRot, 4)])) = NaN;
    toc
    fprintf('Rotated movie\n');

    
    % ------
    
    fprintf('Detecting molecules'' mask\n');
    tic
    
    import AB.Core.get_foreground_mask_movie;
    [fgMaskMov] = get_foreground_mask_movie(movieRot, preprocessSettings.foregroundMasking);
   
    toc
    fprintf('Detected molecules'' mask\n');


    % ------
    fprintf('Conducting filtered connected component analysis on molecules\n');
    tic
    
    minFramePresence = 3;  % filter out components that aren't present in at least this many frames
    import AB.Core.get_filtered_cc_struct;
    [ccStructNoEdgeAdj] = get_filtered_cc_struct(fgMaskMov, minFramePresence, segmentFrameRot);
    
    toc
    fprintf('Conducted filtered connected component analysis on molecules\n');

    % ------
    fprintf('Detecting kymograph edges\n');
    tic

    import AB.Core.detect_kymo_mol_edge_idxs;
    [kymoMolEdgeIdxs, ccIdxs] = detect_kymo_mol_edge_idxs(ccStructNoEdgeAdj, preprocessSettings.kymoEdgeDetection);

    toc
    fprintf('Detected kymograph edges\n');

end
