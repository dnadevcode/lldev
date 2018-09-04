function [rotationAngle] = get_rotation_angle(movieIn, rotationSettings)
    fprintf('Detecting edges\n');
    tic

    angleDetectionFrame = nanmean(movieIn, 4);
    import Microscopy.Utils.sobel_radon_edge_fg_method;
    gradmag = sobel_radon_edge_fg_method(angleDetectionFrame);

    toc
    fprintf('Detected edges\n');

    fprintf('Detecting edge angle\n');
    tic
    
    import OptMap.MovieKymoExtraction.detect_angle_with_radon_transform;
    [rotationAngle] = detect_angle_with_radon_transform(gradmag, rotationSettings.numAngleCandidates, rotationSettings.angleOffset);
    rotationAngle = mod(-rotationAngle, 360);

    toc
    fprintf('Detected edge angle\n');
end