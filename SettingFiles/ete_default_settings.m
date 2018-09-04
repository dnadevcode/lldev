function [ sets ] = ete_default_settings()
    % ete_default_settings
    
    % This loads default settings for ETE_Gui, so the user has an option to
    % manually select some settings here and skip their selection in the
    % GUI
    
    sets.forceStretchToSameBpsPerPixel = true; % should we stretch to the same bp/pixel ratio?

    % Stretching options
    sets.promptUserForStretchFactors = 1; % if we should promt user for stretching factor selection
    sets.stretchFactors = [1]; % all possible stretch factors
    
    % Pre-generated zero model settings
    
    sets.promptUserForZeroModel = 1; % if we should promt user for zero model selection
    sets.zeroModelDir = ''; % if the zero model directory is known
    sets.promptUserForZeroModelType = 1;
    sets.zeroModelResolution = 1; % '1' - bp, '2' - px (old)

    % Is the plasmid circular? 
    sets.promptForCircular = 0; % should we ask user
    sets.isCircular = 1; % default is circular
    
    % how many random barcodes
    sets.numRandBarcodes = 1000;
    
    % should random barcodes be z-scored?
    sets.promtIfZscoreBarcodes = 0;
    sets.zscoredRandBarcodes = 1;
    sets.askForFitModel = 1;
    sets.fitModel = 'functional'; % alternative 'functional', 'GEV', etc. 
    
    
    % barcode generation settings.
    sets.askForBarcodeGenerationSettings = 0; % should we prompt user for these settings
    sets.meanBpExt_nm = 0.3; % nm/bp extension which depends on the experiment
    sets.prestretchPixelWidth_nm = 130; % camera resolution in nm/px
    sets.psfSigmaWidth_nm = 300; % point spread function in nm, usually kept fixed at 300 nm
    
end

