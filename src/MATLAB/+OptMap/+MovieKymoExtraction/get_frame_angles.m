function [frameAngles] = get_frame_angles(videoAmplified, numAngleCandidates)
    % GET_FRAME_ANGLES - retrieves the angle of the lines given a video
    %    with the signal organized in parallel lines at a certain angle
    %
    % Inputs:
    %   videoAmplified
    %     a three-dimensional array where each index in the third
    %     dimension is associated with the image in the other two
    %     dimensions as a video frame and where molecule data is amplified
    %     relative to background noise
    %   angleCandidates
    %     the candidate angles to rotate the video in order to detect
    %     parallel lines at the angle
    % 
    % Outputs:
    %   frameAngles
    %     the angle at which parallel lines were found in the video
    % 
    % Authors:
    %   Saair Quaderi
    
    % TODO: Clean-up and improve efficacy of the rotation angle detection
    %   function
    
    import OptMap.MovieKymoExtraction.detect_angle_with_radon_transform;
    import Fancy.UI.ProgressFeedback.BasicTextProgressMessenger;
    
    numFrames = size(videoAmplified, 3);
    frameAngles = zeros(numFrames, 1);
    progress_messenger = BasicTextProgressMessenger.get_instance();
    progress_messenger.init(sprintf(' Computing angles...\n'));
    
    
    % edgeMovie = zeros(size(movieAmplified));
    for frameNum=1:numFrames
        sharpenedFeatureFrame = videoAmplified(:,:,frameNum);
        [frameAngle] = detect_angle_with_radon_transform(sharpenedFeatureFrame, numAngleCandidates);
%         edgeFrame = edge(sharpenedFeatureFrame);
%         [H, theta, ~] = hough(edgeFrame, 'theta', angleCandidates);
% 
%         % Find the peak pt in the Hough transform.
%         peak = houghpeaks(H);
%         peakThetaIdx = peak(2);
% 
%         % Optimal angle obtained from Hough peaks
%         frameAngle = theta(peakThetaIdx);
%         
        frameAngles(frameNum) = frameAngle;
        % edgeMovie(:,:,frameNum) = edgeFrame;
        progress_messenger.checkin(frameNum, numFrames);
    end
    msgOnCompletion = sprintf('    Computed angles\n');
    progress_messenger.finalize(msgOnCompletion);
end