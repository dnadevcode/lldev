function [ sets ] = set_default_settings_code()
    % This sets default settings so that if we want, we can run the program
    % without any prompts, good if we want to run multiple things..

    % alignment settings
    sets.promptForTimeFr = 0;
    sets.timeFramesNr = 200;
    sets.skipAlignChoice = 0;
    sets.alignMethod = 1; % 0 - nralign, 1 - ssdalign

    % edge detection settings
    skipDoubleTanhAdjustment = true;
    import OptMap.MoleculeDetection.EdgeDetection.get_default_edge_detection_settings;
    sets.edgeDetectionSettings = get_default_edge_detection_settings(skipDoubleTanhAdjustment);
    
    % ssd align settings
    sets.ssdAlignSettings = [];
    sets.stretchPar = 2;

    % barcode consensus settings 
    sets.skipbarcodeConsensusSettings = 1; % skip barcode consensus settings
    sets.skipDefaultConsensusSettings = 1;
    sets.skipbarcodeClusterSettings = 1;
    sets.barcodeConsensusSettings.aborted = 0;
    sets.barcodeConsensusSettings.promptForBarcodeClusterLimit = 0;
    sets.barcodeConsensusSettings.barcodeClusterLimit = 0.5;
   % sets.barcodeConsensusSettings.clusterScoreThresholdNormalized = 0.5;
    sets.barcodeConsensusSettings.barcodeNormalization = 'bgmean';
    sets.barcodeConsensusSettings.prestretchPixelWidth_nm = 130;
    sets.barcodeConsensusSettings.psfSigmaWidth_nm = 300;
    sets.barcodeConsensusSettings.deltaCut = 3;

    sets.barcodeConsensusSettings.prestretchUntrustedEdgeLenUnrounded_pixels =  sets.barcodeConsensusSettings.deltaCut * sets.barcodeConsensusSettings.psfSigmaWidth_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
    %sets.barcodeConsensusSettings.meanBpExt_nm = 0.2693; % from lambda experiments! pUUH

    % stretching
    sets.skipPrechoice = 1;
    sets.prestretchMethod = 1; % 0 - do not prestretch % 1 - prestretch to common length
    sets.barcodeConsensusSettings.skipStretch = 1; %0 - do not stretch,  1 - stretch
    sets.barcodeConsensusSettings.stretchFactors = [0.95 0.96 0.9700    0.9800    0.9900    1.0000    1.0100    1.0200    1.0300 1.04 1.05];
        % 
    % filter settings
    sets.skipFilterSettings = 1;
	sets.filterSettings.filter=1; % 0 - do not filter, 1 - filter
	sets.filterSettings.promptForfilterSettings = 0;
    sets.filterSettings.prestretchMethod = 1; % why is this?
    sets.filterSettings.timeFramesNr = 1;
    sets.filterSettings.filterMethod = 0; % 0 - filter after stretching, 1 - before
    sets.filterSettings.filterSize = sets.barcodeConsensusSettings.psfSigmaWidth_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
    
    % Theory generation
    sets.skipBarcodeGenSettings = 1;
    sets.skipChangeBpNmRatio = 1;

    sets.theoryFilePath = '/home/albyback/git/WORKSHOP/HCA_v1.6/ch22_1.1_P18_0,225nmbp.mat';
    sets.barcodeGenSettings.meanBpExt_nm = 0.225;
    sets.barcodeGenSettings.pixelWidth_nm = 130;
    sets.barcodeGenSettings.concNetropsin_molar = 6;
    sets.barcodeGenSettings.concYOYO1_molar = 0.02;
    sets.barcodeGenSettings.isLinearTF = 0;
    sets.barcodeGenSettings.psfSigmaWidth_nm = 300;
    sets.barcodeGenSettings.deltaCut = 3;
    sets.barcodeGenSettings.widthSigmasFromMean = 4;
    sets.barcodeGenSettings.yoyo1BindingConstant = 26;
    
    sets.skipNullModelChoice = 1;
    sets.nullModelPath = '/home/albyback/git/WORKSHOP/HCA_v1.6/nullmodel';
    sets.askForPvalueSettings = 0;
    sets.pvaluethresh = 0.01;
    sets.contigSettings.numRandBarcodes = 1000;

end

