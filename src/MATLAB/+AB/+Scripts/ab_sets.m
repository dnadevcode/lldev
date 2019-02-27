function [ sets ] = ab_sets()
    sets = struct();

    sets.moviesets.askformovie = 1; % should we ask for a filefolder, or is it already provided down here
    %sets.movie.promtformovie = 0;
%     sets.moviefilefold{1} = '/home/albyback/git/rawData/automation/sample n21 tif files to Albertas/';
%     sets.filenames{1} = 'Experiment-602.tif';
%     sets.moviefilefold{1} = '/media/albyback/My Passport/DATA/AB_Testing/2018-11-02 Example Barcode movies for Albertas/';
%     sets.filenames{1} = '2plex_block1_pt2_tile1.tif';
%     sets.moviefilefold{1} = '/home/albyback/git/rawData/AB/sim/';
%     sets.filenames{1} = '1_22_movie.tif';
    sets.moviefilefold{1} = '/home/albyback/rawData/dnaData/autobarcodingData/exp/2plex/';
    sets.filenames{1} = '2plex_block1_pt2_tile1.tif';
    sets.kymo.avgL = 3; % this*2+1 pixels are averaged to compute the kymograph
    
    %%
    sets.promtsetsconsensus = 0; % should we prompt for consensus settings
    sets.consensus.psf = 300;
    sets.consensus.pxnm = 130;
    sets.consensus.dc = 3;
    sets.consensus.ct = 0;
    sets.consensus.lenRangeFactor = 1.2;
    sets.consensus.skipPromt = 1; % skip consensus promt
    sets.consensus.normSetting = 'zscore';
    % settings for angle detection
    sets.promtsetspreprocessing = 0;

    %% rotation
    sets.preprocessing.rotation.numAngleCandidates = 180*20;
    sets.preprocessing.rotation.angleOffset = 0;

    %% foreground masking
    sets.preprocessing.foregroundMasking.maxAmpDist = 2; % maximum amplitude distance
	sets.preprocessing.foregroundMasking.maxSigmaNonBlip = 3; % maximum variance between non blips

  %% edge detection
    sets.preprocessing.kymoEdgeDetection.morphExpansion = 5;
    sets.preprocessing.kymoEdgeDetection.morphShrinking = 3;
    sets.preprocessing.kymoEdgeDetection.windowWidth = 3;
  
end

