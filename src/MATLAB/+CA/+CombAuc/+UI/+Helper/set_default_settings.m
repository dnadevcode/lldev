function [ sets ] = set_default_settings()
    % This sets default settings so that if we want, we can run the program
    % without any prompts, good if we want to run multiple things..
% 
%     sets.kymoFold = '/home/william/som16_albertas/git/rawData/chromosomes/Data For Albertas/Files/2330P18/Raw Kymos';
% 
%     % alignment settings
%     sets.timeFramesNr = 200;
%     sets.alignMethod = 0; % 0 - nralign, 1 - ssdalign
% 
%     % edge detection settings
%     skipDoubleTanhAdjustment = true;
%     import OptMap.MoleculeDetection.EdgeDetection.get_default_edge_detection_settings;
%     sets.edgeDetectionSettings = get_default_edge_detection_settings(skipDoubleTanhAdjustment);
%     
%     % ssd align settings
%     sets.ssdAlignSettings = [];
% 
%     % barcode consensus settings 
%     sets.barcodeConsensusSettings.aborted = 0;
%     sets.barcodeConsensusSettings.promptForBarcodeClusterLimit = 1;
%     sets.barcodeConsensusSettings.barcodeClusterLimit = 0.75;
%     sets.barcodeConsensusSettings.clusterScoreThresholdNormalized = 0.75;
%     sets.barcodeConsensusSettings.barcodeNormalization = 'zscore';
%     sets.barcodeConsensusSettings.prestretchPixelWidth_nm = 130;
%     sets.barcodeConsensusSettings.psfSigmaWidth_nm = 300;
%     sets.barcodeConsensusSettings.deltaCut = 3;
%     sets.barcodeConsensusSettings.prestretchUntrustedEdgeLenUnrounded_pixels =  sets.barcodeConsensusSettings.deltaCut * sets.barcodeConsensusSettings.psfSigmaWidth_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
% 
%     % stretching
%     sets.prestretchMethod = 1; % 0 - do not prestretch % 1 - prestretch to common length
%     sets.barcodeConsensusSettings.skipStretch = 1; %0 - do not stretch,  1 - stretch
%     sets.barcodeConsensusSettings.stretchFactors = [ 0.9700    0.9800    0.9900    1.0000    1.0100    1.0200    1.0300];
%         % 
%     % filter settings
% 	sets.filterSettings.filter=1; % 0 - do not filter, 1 - filter
% 	sets.filterSettings.promptForfilterSettings = 1;
%     sets.filterSettings.prestretchMethod = 1; %
%     sets.filterSettings.timeFramesNr = 1;
%     sets.filterSettings.filterMethod = 0; % 0 - filter after stretching, 1 - before
%     % Theory generation
%     sets.theoryFilePath = '/home/william/som16_albertas/Downloads/HCA_v1.5/ch22_1.1_P18_0,225nmbp.mat';
%    % sets.theoryFilePath = '/home/albyback/git/WORKSHOP/HCA_v1.4.4/ch22_1.1_P18_0,225nmbp.mat';

end

