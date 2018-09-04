function [valsArrForegroundMask, fgThreshold] = approx_fg_mask_using_context_stats(valsArr, foregroundSeparationSettings, backgroundProfile)
    % APPROX_FG_MASK_USING_CONTEXT_STATS - approximates where the
    %   foreground is and creates a bitmask for it using contextual stats
    %   about what the (assumed to be gaussian) background intensity
    %   distribution and settings for the number of standard deviations
    %   above the mean background intensity that the foreground intensities
    %   are to threshold and the strel objects for imclose and imopen
    %   morphological operations to perform on the thresholded mask to
    %   acquire the final approximation of the foreground mask
    %
    % Inputs:
    %   valsArr
    %     the array with the intensity values
    %   foregroundSeparationSettings
    %     struct with fields:
    %        numSigmaThreshold (the number of sigma at or above the background's
    %           "upper" mean where we want the threshold between background
    %           and foreground to be placed)
    %        imcloseStrelNhood (optional, neighborhood for imclose operation that occurs after thresholding)
    %        imopenStrelNhood (optional, neighborhood for imopen operation that occurs after imclose operation)
    %   backgroundProfile
    %     struct with fields:
    %        meanUpper (upper version of background intensity mean at a certain confidence)
    %        stdUpper (upper version of background intensity variance at a certain confidence)
    %
    % Outputs:
    %   valsArrForegroundMask
    %     logical array of same size as valsArr with true wherever
    %      the foreground is approximated to be present
    %   fgThreshold
    %     the minimal threshold value for foreground intensity values
    %       other than those added by image morphological operators
    %
    % Authors:
    %   Saair Quaderi
    
    backgroundMeanUpper = backgroundProfile.meanUpper;
    backgroundStdUpper = backgroundProfile.stdUpper;
    numSigmaThreshold = foregroundSeparationSettings.numSigmaThreshold;
    fgThreshold = (numSigmaThreshold * backgroundStdUpper) + backgroundMeanUpper;
    valsArrForegroundMask = valsArr >= fgThreshold;
    
    if isfield(foregroundSeparationSettings, 'imcloseStrelNhood')
        imcloseStrelNhood = foregroundSeparationSettings.imcloseStrelNhood;
        if not(isempty(imcloseStrelNhood))
            valsArrForegroundMask = imclose(valsArrForegroundMask, imcloseStrelNhood);
        end
    end
    
    if isfield(foregroundSeparationSettings, 'imopenStrelNhood')
    imopenStrelNhood = foregroundSeparationSettings.imopenStrelNhood;
        if not(isempty(imopenStrelNhood))
            valsArrForegroundMask = imopen(valsArrForegroundMask, imopenStrelNhood);
        end
    end
end