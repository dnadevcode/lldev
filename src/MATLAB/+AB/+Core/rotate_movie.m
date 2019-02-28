function [movieRot, rRot, cRot, segmentFrameRot] = rotate_movie(movieIn, rotationAngle)
    % rotate_movie. This rotates the movie
    %
    % :param movieIn: movie input.
	% :param rotationAngle: rotation angle.

    % :returns: movieRot, rRot, cRot, segmentFrameRot
    
    szMovieIn = size(movieIn);
    
    % create a Cartesian grid 
    [c, r] = meshgrid((1:szMovieIn(2)), (1:szMovieIn(1)));

    % rotation sampling method
    rotationSamplingMethod = 'bilinear';
    
    % bounding box mode
    bboxMode = 'loose';
    
    % rotate the whole movie
    movieRot = imrotate(movieIn, rotationAngle, rotationSamplingMethod, bboxMode);
    
    % method for coordinate matrix should be 'nearest' to avoid artifacts
    % when doing bilinear interpolation (then between 200 and 0 there's
    % 100, while in fact it should be 0. Note that this only allows us to
    % see where there are nonzero pixels, though we can't use them to index
    % the coordinates. todo: do both
    rotationSamplingMethod = 'nearest';

    % rotate the Y coordinate matrix
    rRot = imrotate(r, rotationAngle, rotationSamplingMethod, bboxMode);
    
    % rotate the X coordinate matrix
    cRot = imrotate(c, rotationAngle, rotationSamplingMethod, bboxMode);
    
    % we care only abound indices that were in original grid. These are the
    % points that have length(y)>=r>=1, length(x)>c>=1. 
    % can we find cases where extra points are denoted as non zero?
    segmentFrameRot = (rRot >= 1) & (rRot <= szMovieIn(1)) & (cRot >= 1) & (cRot <= szMovieIn(2));
end