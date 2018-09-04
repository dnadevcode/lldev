function [ sets ] = set_default_settings()
    % This sets default settings so that if we want, we can run the program
    % without any prompts, good if we want to run multiple things..

    % alignment settings
    sets.promptForTimeFr = 1;
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
    sets.skipbarcodeConsensusSettings = 0; % skip barcode consensus settings
    sets.skipDefaultConsensusSettings = 0;
    sets.skipbarcodeClusterSettings = 0;
    sets.barcodeConsensusSettings.aborted = 0;
    sets.barcodeConsensusSettings.promptForBarcodeClusterLimit = 1;
    sets.barcodeConsensusSettings.barcodeClusterLimit = 0.5;
    sets.barcodeConsensusSettings.barcodeNormalization = 'zscore';
    sets.barcodeConsensusSettings.prestretchPixelWidth_nm = 130;
    sets.barcodeConsensusSettings.psfSigmaWidth_nm = 300;
    sets.barcodeConsensusSettings.deltaCut = 3;
    sets.barcodeConsensusSettings.barcodesInConsensus = []; % barcodes that are in the consensus

    sets.barcodeConsensusSettings.prestretchUntrustedEdgeLenUnrounded_pixels =  sets.barcodeConsensusSettings.deltaCut * sets.barcodeConsensusSettings.psfSigmaWidth_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
    %sets.barcodeConsensusSettings.meanBpExt_nm = 0.2693; % from lambda experiments! pUUH

    % stretching
    sets.skipPrechoice = 0;
    sets.prestretchMethod = 1; % 0 - do not prestretch % 1 - prestretch to common length
    sets.barcodeConsensusSettings.skipStretch = 1; %0 - do not stretch,  1 - stretch
    sets.barcodeConsensusSettings.stretchFactors = [ 0.9700    0.9800    0.9900    1.0000    1.0100    1.0200    1.0300];
        % 
    % filter settings
    sets.skipFilterSettings = 0;
	sets.filterSettings.filter=1; % 0 - do not filter, 1 - filter
	sets.filterSettings.promptForfilterSettings = 1;
   % sets.filterSettings.prestretchMethod = 1; %
    sets.filterSettings.timeFramesNr = 1;
    sets.filterSettings.filterMethod = 1; % 0 - filter after stretching, 1 - before
    sets.filterSettings.filterSize = sets.barcodeConsensusSettings.psfSigmaWidth_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
    sets.filterSettings.barcodesInConsensus = []; % barcodes that are in the consensus


    % Theory generation
    sets.skipBarcodeGenSettings = 0;
    sets.skipChangeBpNmRatio = 0;
    %sets.theoryFilePath = '/home/albyback/git/WORKSHOP/HCA_v1.6/ch22_1.1_P18_0,225nmbp.mat';
    sets.barcodeGenSettings.meanBpExt_nm = 0.225;
    sets.barcodeGenSettings.pixelWidth_nm=130;
    sets.barcodeGenSettings.concNetropsin_molar=6;
    sets.barcodeGenSettings.concYOYO1_molar=0.02;
    sets.barcodeGenSettings.concDNA = 0.2;
    sets.barcodeGenSettings.isLinearTF = 0;
    sets.barcodeGenSettings.deltaCut = 3;
    sets.barcodeGenSettings.widthSigmasFromMean = 4;
    sets.barcodeGenSettings.yoyo1BindingConstant = 26; % yoyo binding constant
    sets.barcodeGenSettings.computeFreeConcentrations = 1;
    
    sets.skipNullModelChoice = 0;
   % sets.nullModelPath = '/home/albyback/git/WORKSHOP/HCA_v1.6/nullmodel';
    sets.pvaluethresh = 0.01;
end

