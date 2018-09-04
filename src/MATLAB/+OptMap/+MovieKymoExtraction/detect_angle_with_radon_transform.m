function [angle] = detect_angle_with_radon_transform(img, numAngleCandidates, angleOffset)
    % RADON_ROTATE - find the angle of parallel lines in the image
    % 
    % Inputs:
    %   img
    %     the image in which to find parallel lines
    %   numAngleCandidates (optional; defaults to 180)
    %     the number of angle candidates at which to check for parallel
    %     lines in the image (spread equally spaced in range [-90, 90) 
    %     and always including the angleOffset
    %   angleOffset (optional; defaults to 0 [degrees])
    %     angleOffset allows the angle the range is centered at to be
    %     adjusted to a different value than 0 degrees
    %
    % Outputs:
    %   angle
    %     the angle of the detected parallel lines in degrees
    %     will be in range angleOffset + [-90, 90)
    %
    % Authors:
    %  Saair Quaderi
    if nargin < 2
        numAngleCandidates = 180;
    end
    if nargin < 3
        angleOffset = 0;
    end
    
    theta = angleOffset + (180*(0:(numAngleCandidates - 1))./numAngleCandidates);
    theta = [theta(theta >= 90) - 180, theta(theta < 90)];
    R = radon(img, theta);
    
    % [R, xp] = radon(img, theta);
    % figure
    % imagesc(theta, xp, R);
    % colormap(hot);
    % xlabel('\theta (degrees)'); ylabel('x\prime');
    % title('R_{\theta} (x\prime)');
    % colorbar
    
    varR = var(R);
    if length(varR) > 2
        [~, peakLocIdxs] = findpeaks([varR(end), varR, varR(1)]);
        peakLocIdxs = peakLocIdxs - 1;
    else
        peakLocIdxs = 1:length(varR);
    end
    varRFirstDeriv = diff([varR(end), varR]);
    varRSecondDeriv = diff([varRFirstDeriv(end), varRFirstDeriv]);
    
    % figure
    % plot(theta, [zscore(varR(:)), zscore(varRFirstDeriv(:)), zscore(varRSecondDeriv(:))], '-x');
    % xlabel('\theta (degrees)'); ylabel('x\prime');
    
    [~, thetaIdxApprox] = min(varRSecondDeriv);
    [~, tmpIdx] = min(abs(peakLocIdxs - thetaIdxApprox));
    thetaIdx = peakLocIdxs(tmpIdx);
    thetaVal = theta(thetaIdx);
    
    % figure
    % imshow(imrotate(img, -thetaVal))
    % figure
    % plot(xp, R(:, thetaIdx))
    
    angle = -thetaVal;
end