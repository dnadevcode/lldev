function [movieRot, rRot, cRot, segmentFrameRot] = rotate_movie(movieIn, rotationAngle)
    szMovieIn = size(movieIn);
    [c, r] = meshgrid((1:szMovieIn(2)), (1:szMovieIn(1)));

    rotationSamplingMethod = 'bilinear';
    bboxMode = 'loose';

    movieRot = imrotate(movieIn, rotationAngle, rotationSamplingMethod, bboxMode);
    rRot = imrotate(r, rotationAngle, rotationSamplingMethod, bboxMode);
    cRot = imrotate(c, rotationAngle, rotationSamplingMethod, bboxMode);
    segmentFrameRot = (rRot >= 1) & (rRot <= szMovieIn(1)) & (cRot >= 1) & (cRot <= szMovieIn(2));
end