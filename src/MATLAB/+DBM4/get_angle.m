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
    % filter some short things out
    meanGrayFrameEdgesFilt = bwareafilt(logical(meanGrayFrameEdges),[20 inf]);
    % Hough transform.
    [H, theta, ~] = hough(meanGrayFrameEdgesFilt, 'theta', -90:.01:89.99);

    % Find the peak pt in the Hough transform.
    peak = houghpeaks(H,1); % maybe take more?

    % Optimal angle obtained from Hough peaks
    angle = mean(mod(theta(peak(:,2)), 360));
    
    
    
%     %%
%     angles = zeros(1,size(grayFrames,3));
%     for i=1:size(grayFrames,3)
%         meanGrayFrame = grayFrames(:,:,i);
%         % Correct for uneven illumination.
%         se = strel('disk', 12);
%         meanGrayFrame = imtophat(meanGrayFrame, se);
% 
%         % Edge detection
%         meanGrayFrameEdges = edge(meanGrayFrame);
% 
%         % Hough transform.
%         [H, theta, ~] = hough(meanGrayFrameEdges, 'theta', -90:.01:89.99);
% 
%         % Find the peak pt in the Hough transform.
%         peak = houghpeaks(H);
% 
%         % Optimal angle obtained from Hough peaks
%         angle = mod(theta(peak(2)), 360);
%         angles(i) = angle;
%     end
    
end
