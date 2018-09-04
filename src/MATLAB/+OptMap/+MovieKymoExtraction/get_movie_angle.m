function [movieAngle] = get_movie_angle(movieAmplified, numAngleCandidates, useFramewiseConsensus)
    import OptMap.MovieKymoExtraction.get_frame_angles;

    if useFramewiseConsensus
        frameAngles = get_frame_angles(movieAmplified, numAngleCandidates);
        sortedFrameAngles = sort(frameAngles);
        movieAngle = sortedFrameAngles(floor((end + 1)/2));
    else
        movieAngle = get_frame_angles(mean(movieAmplified, 3), numAngleCandidates);
    end
    
end