function [rotationAngle] = get_rotation_angle(movieIn, rotationSettings)
    % get_rotation_angle
    
    % :param movieIn: input movie, should be 3d array
    % :param rotationSettings: settings for detecting rotaton angle
    %
    % :returns: rotationAngle
    
    % rewritten and commented by Albertas Dvirnas
    
    fprintf('Computing gradient image\n');
    tic
    % Compute the mean over all timeframes.
    I = double(nanmean(movieIn, 3));
%     
%     % Find gradient image using Sobel, http://homepages.inf.ed.ac.uk/rbf/HIPR2/sobel.htm
% 	hy = fspecial('sobel');
%     Iy = imfilter(I, hy, 'replicate');
%     Ix = imfilter(I, hy', 'replicate');
%     gradmag = abs(Ix)+abs(Iy);
%     %gradmag = sqrt(Ix.^2 + Iy.^2);
%     toc
    
    gradmag = edge(I,'Sobel');

   
    fprintf('Computed gradient image\n');
%     import Microscopy.Utils.sobel_radon_edge_fg_method;
%     gradmag = sobel_radon_edge_fg_method(angleDetectionFrame);
%     bw =edge(gradmag);
% 
% 	[row, col] = ind2sub(size(bw), find(~isnan(bw)));
%     vals = [row col];
% 	[coeff,score,latent,tsquared,explained,mu]= pca(vals);
%     bw= edge(I,'Sobel');
    % find angle using principal component analysis
%     rotationAngle = asin(coeff(1,1)) * 180 / pi;
   % k = tan((abs(angle) * pi) / 180);

   % fprintf('Detected edge angle\n');
   % fprintf('Detecting edge angle\n');
  %  tic
    import OptMap.MovieKymoExtraction.detect_angle_with_radon_transform;
    [rotationAngle] = detect_angle_with_radon_transform(gradmag, rotationSettings.numAngleCandidates, rotationSettings.angleOffset);
    rotationAngle = mod(-rotationAngle, 360);
   % toc
end