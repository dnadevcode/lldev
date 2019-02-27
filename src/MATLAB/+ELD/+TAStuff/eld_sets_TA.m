function [ sets ] = eld_sets()
    % function with default eld_settings
    sets = struct();
    
    %%
    sets.moviesets.askformovie = 0;
	sets.filenames{1}  = 'redch40_25_MMStack.ome-1.tif';
   	%sets.moviefilefold{1} = '/home/albyback/git/Projects/ELD/Tif files - FSHD fluctuations in nanochannels/Original crops/';
    sets.moviefilefold{1} = 'example/';
    sets.moviesets.askforkymo = 0;

%         
%     if nargin < 1 % this should instead return some error perhaps
%         sets.kymoFold = '/home/albyback/git/Projects/HMM/structural variation kymo/P5K0/';
%     else
%         sets.kymoFold = kymoFold;
%     end
       
    %sets.kymoFold = '/home/albyback/Dropbox/kymo180420 (0.238nmPERbp)/1.6x Optovar (130nm Pixels)/';
%     addpath(genpath(sets.kymoFold));
    
    sets.medianfilter = [3 3];
    sets.threshLevel = 4;
    
    % Filter
    sets.amplification.amplificationKernel = struct(...
        'spacialNeighborhoodRadius', 2.0,...
        'temporalNeighborhoodHalfLen', 2.0,...
        'spacialDimDistanceWarpingPower', 2.0,...
        'temporalDimDistanceWarpingPower', 2.0);
    %--------- ROTATE MOVIE
    sets.rotation.useFramewiseConsensus = false;
    sets.rotation.angleStep = 0.1;
    
    % channel extraction 
    sets.channelDetection.channelWidthPx = 5; % do some robustness analysis
    
    sets.targetSequence = 'TCGA';
    sets.sigma = 1.3;
    
    %% Peak extraction 
    % local fluctuation window
    sets.localFluctuationWindow = 3;
    % minimum length of a connected component
    sets.minConC = 50;
    % Minimum required vertical overlap between features (in pixels), for calculating the distance between the features. If two features overlap by less than this amount, they are considered non-overlapping.
    sets.minVertOverlap = 5;
   % The maximum multiple of standard deviations by which two features can lie from one another, and still be considered to belong to the same fluorophore. Distances are calculated between all features, and standard deviations for these distances are calculated as well. If two features a and b lie within confidenceInterval*sigma_ab from one another, they are considered belonging to the same fluorophore. ;
    sets.confidenceInterval = 2;
    % allow feature crossings or not? 0 = false, 1 = true
    sets.allowCrossings = 1;

end

