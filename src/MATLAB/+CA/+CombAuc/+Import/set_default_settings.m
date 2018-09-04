function [ sets ] = set_default_settings()
    % This sets default settings so that if we want, we can run the program
    % without any prompts, good if we want to run multiple things..
% 
	sets.kymoFold = '/home/albyback/git/rawData/pUUH Data/DA15001/';
% 
%     % alignment settings
%     sets.timeFramesNr = 200;
	sets.alignMethod = 1; % 0 - nralign, 1 - ssdalign
     
    % ssd alignment settings
    sets.stretchPar = 1;
    sets.alowedShift = 10*sets.stretchPar;
    sets.pxMax = 550*sets.stretchPar;
    sets.shiftInd = 40*sets.stretchPar;
% 
    % edge detection settings
%     skipDoubleTanhAdjustment = true;
%     import OptMap.MoleculeDetection.EdgeDetection.get_default_edge_detection_settings;
%     sets.edgeDetectionSettings = get_default_edge_detection_settings(skipDoubleTanhAdjustment);
    
%     % ssd align settings
%     sets.ssdAlignSettings = [];
% 
    % barcode consensus settings 
    sets.barcodeConsensusSettings.aborted = 0;
    sets.barcodeConsensusSettings.promptForBarcodeClusterLimit = 1;
    sets.barcodeConsensusSettings.barcodeClusterLimit = 0.75;
    sets.barcodeConsensusSettings.clusterScoreThresholdNormalized = 0;
    sets.barcodeConsensusSettings.barcodeNormalization = 'bgmean';
    sets.barcodeConsensusSettings.prestretchPixelWidth_nm = 159.2;
    sets.barcodeConsensusSettings.psfSigmaWidth_nm = 300;
    sets.barcodeConsensusSettings.deltaCut = 3;
    sets.barcodeConsensusSettings.prestretchUntrustedEdgeLenUnrounded_pixels =  sets.barcodeConsensusSettings.deltaCut * sets.barcodeConsensusSettings.psfSigmaWidth_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
% 
%     % stretching
      sets.prestretchMethod = 1; % 0 - do not prestretch % 1 - prestretch to common length
      sets.barcodeConsensusSettings.skipStretch = 1; %0 - do not stretch,  1 - stretch
      %sets.barcodeConsensusSettings.stretchFactors = [ 0.9700    0.9800    0.9900    1.0000    1.0100    1.0200    1.0300];
      sets.barcodeConsensusSettings.stretchFactors = [ 1];

      %         % 
%     % filter settings
	sets.filterSettings.filter=0; % 0 - do not filter, 1 - filter
% 	sets.filterSettings.promptForfilterSettings = 1;
%     sets.filterSettings.prestretchMethod = 1; %
%     sets.filterSettings.timeFramesNr = 1;
	sets.filterSettings.filterMethod = 0; % 0 - filter after stretching, 1 - before
    sets.filterSettings.filterSize = 0;
    %     % Theory generation
	%sets.theoryFilePath = '/home/william/som16_albertas/git/combinatorial_contig_assembly/Codes/Test/plasmid_puuh.mat';
    %sets.theoryFilePath = '/home/william/som16_albertas/git/combinatorial_contig_assembly/Codes/Test/plasmid_plos005b.mat';

%    % sets.theoryFilePath = '/home/albyback/git/WORKSHOP/HCA_v1.4.4/ch22_1.1_P18_0,225nmbp.mat';
    sets.barcodeConsensusSettings.meanBpExt_nm = 0.2693; % from lambda experiments! pUUH
        sets.meanBpExt_nm = 0.2693; % from lambda experiments! pUUH

   %     sets.meanBpExt_nm = 0.2958; % from lambda experiments! plos005B

    sets.defaultBarcodeGenSettings.isLinearTF = false;
    
    
      % Competitive binding parameters:
    sets.defaultBarcodeGenSettings.concNetropsin_molar = 6; % Netropsin concentration, units molar
    sets.defaultBarcodeGenSettings.concYOYO1_molar = 4e-2; % YOYO-1 concentration, units molar
    sets.defaultBarcodeGenSettings.yoyo = 26;
    sets.defaultBarcodeGenSettings.concDNA = 0.2;

    
    % contig settings
    
   % sets.contigSettings.minValidShortestSeq = 4 * barcodeGenSettings.psfSigmaWidth_nm / barcodeGenSettings.meanBpExt_nm;
    sets.contigSettings.qMax = round(5*10^5);
    sets.contigSettings.overlapLim = 2;
    sets.contigSettings.allowOverlap = (sets.contigSettings.overlapLim > 0);
    sets.contigSettings.forcePlace = false;
    sets.contigSettings.pThreshold = 0.501;
    sets.contigSettings.data = 'Unknown';
    sets.contigSettings.numRandBarcodes = 1000; %number of PR barcodes
    sets.contigSettings.flipAllowed = true;
    sets.contigSettings.shouldFormatNamesTF = true;
    sets.contigSettings.pValueThresh = 0.001;
    sets.contigSettings.maxDistance = 2;
 
    % Micriscopy point spread function and pixel sampling related
    % parameters:
  %  sets.defaultBarcodeGenSettings.meanBpExt_nm = 0.225; % mean extension length per basepair, units nm
    
    % TODO: reconsider fundamental purpose of this parameter and whether
    %  it's variance meanBpExt_nm/uncertainty in psfSigmaWidth_nm/something
    %  else more specific that should be explicitly represented instead
    %defaultBarcodeGenSettings.stretchFactor = 1; % factor for stretching barcode (1 = no stretching/compressing)
    
    % Relevant for experimental barcode bitmasks:
   % defaultBarcodeGenSettings.deltaCut = 3; % multiple of point spread function standard deviation representing distance from experimental barcode cuts/edges where values are not considered sufficiently trustworthy

    
    %defaultBarcodeGenSettings.isLinearTF = false; % whether to treat non-circularly (e.g. not using circular convolution of PSF)
    %defaultBarcodeGenSettings.widthSigmasFromMean = 4; % number of psf widths to make the hSize for the gaussian kernel for PSF

end

