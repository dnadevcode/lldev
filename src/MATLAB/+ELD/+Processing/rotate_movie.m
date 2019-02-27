function [rotatedMovie, rotatedAmp, angle ] = rotate_movie( movie,sets )
    % rotate_movie
    %
	% first amplify kernel. According to the manuscript, we amplify with 3d
    % gaussian filter with sigmas (2,1,2) why? But here we use different
    % code from process_dot_movie. Also, dead pixels should not be involved
    % in this at all...
    
    % :param movie: movie
    % :param sets: sets
    % :returns: rotatedMovie, rotatedAmp, angle
    
    % rewritten by Albertas Dvirnas
    
    import Microscopy.generate_amplification_kernel;
    tmp_amplificationKernel_neighborhoodCutoffDistByDim = [sets.amplification.amplificationKernel.spacialNeighborhoodRadius.*ones(1, 2), sets.amplification.amplificationKernel.temporalNeighborhoodHalfLen]; % distance cutoffs in each dimension
    tmp_amplificationKernel_distWarpingPowers = [sets.amplification.amplificationKernel.spacialDimDistanceWarpingPower.*ones(1, 2), sets.amplification.amplificationKernel.temporalDimDistanceWarpingPower]; % how much the distances should be warped
    [tmp_amplificationKernel] = generate_amplification_kernel(tmp_amplificationKernel_neighborhoodCutoffDistByDim, tmp_amplificationKernel_distWarpingPowers);
    
    % Amplify with kernel
    import Microscopy.amplify_molecules;
    disp('Generating amplified movie for foreground detection...');
    [amplifiedMovie] = amplify_molecules(movie, tmp_amplificationKernel);
    
    ampIm = amplifiedMovie(:,:,1);
      
    theta = 0:sets.rotation.angleStep:180;
    R = radon(ampIm, theta);
    
    [i,j] = max(max(R));
    angle = j*sets.rotation.angleStep-90;
  
    angle = -angle;
    
    rotatedMovie = imrotate(movie,angle, 'bilinear', 'crop');
    
    rotatedAmp = imrotate(amplifiedMovie,angle, 'bilinear', 'crop');

end

