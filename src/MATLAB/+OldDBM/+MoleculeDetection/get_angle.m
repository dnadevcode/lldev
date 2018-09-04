function angle = get_angle(grayFrames)
    % GET_ANGLE
    %
    % Inputs:
    %	grayFrames
    %
    % Outputs:
    %	angle -the angle of the edges in the movie
    %
    % By: Charleston Noble
    % (Edited by Saair Quaderi)


    % Average the intensities
    meanGrayFrame = mean(grayFrames,3);

    % Correct for uneven illumination.
    se = strel('disk', 12);
    meanGrayFrame = imtophat(meanGrayFrame, se);

    % Edge detection
    meanGrayFrameEdges = edge(meanGrayFrame);

    % Hough transform.
    [H, theta, ~] = hough(meanGrayFrameEdges, 'theta', -90:.01:89.99);

    % Find the peak pt in the Hough transform.
    peak = houghpeaks(H);

    % Optimal angle obtained from Hough peaks
    angle = mod(theta(peak(2)), 360);
end
