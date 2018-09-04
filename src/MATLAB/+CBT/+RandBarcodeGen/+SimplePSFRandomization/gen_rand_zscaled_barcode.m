function [pseudoTheoryBarcode_pxRes, pseudoTheoryBarcode_bpRes] = gen_rand_zscaled_barcode(barcodeLen_bps, meanBpsPerPsfSigmaWidth, meanBpsPerPixel)
    % GEN_RAND_ZSCALED_BARCODE - function to generate z-scaled
    %  (reisner-rescaled) circular barcodes that look like theory barcodes
    %   ignoring that ligands can't overlap in reality and assuming
    %   Netropsin binds every time there are four A/Ts in a row, that
    %   the nucleotide sequence is totally random, and that that Yoyo-1
    %   binds everwhere that Netropsin doesn't
    %
    %   (in practice these look indistinguishable from random theory
    %    barcodes after reisner-rescaling with binding constants used as
    %     of Nov. 2016)
    %
    % Inputs:
    %   barcodeLen_bps (optional; defaults to 1e5)
    %     how long the barcode should be as measured in basepairs
    %   meanBpsPerPsfSigmaWidth (optional; defaults based on default
    %     barcode gen settings -- e.g. 1020 bp = (3.4 bp/nm) * (300 nm))
    %     how big the gaussian point spread function's deviation should be
    %     in basepairs (assuming uniform bp extension along barcode)
    %   meanBpsPerPixel (optional; defaults based on default
    %     barcode gen settings -- e.g 541.28 bp = (3.4 bp/nm) * (159.2 nm))
    %     how many bps on average are expected in each pixel (as can be
    %     calculated with the mean bp extension in nm and the pixel width 
    %     in nanometers)
    %
    % Outputs:
    %   pseudoTheoryBarcode_pxRes
    %     barcode in pixel resolution (just sampling
    %      pseudoTheoryBarcode_bpRes a given interval of bps/pixel)
    %   pseudoTheoryBarcode_bpRes
    %     barcode in basepair resolution

    if (nargin < 1) || isempty(barcodeLen_bps)
        barcodeLen_bps = 1e5;
    end
    if (nargin < 2)
        import CBT.get_default_barcode_gen_settings;
        barcodeGenSettings = get_default_barcode_gen_settings();
        if (nargin < 2) || isempty(meanBpsPerPsfSigmaWidth)
            psfSigmaWidth_nm = barcodeGenSettings.psfSigmaWidth_nm;
            meanBpExt_nm = barcodeGenSettings.meanBpExt_nm;
            meanBpsPerPsfSigmaWidth = psfSigmaWidth_nm/meanBpExt_nm;
        end
        if (nargin < 3) || isempty(meanBpsPerPixel)
            meanBpExt_nm = barcodeGenSettings.meanBpExt_nm;
            pixelWidth_nm = barcodeGenSettings.pixelWidth_nm;
            meanBpsPerPixel = round(pixelWidth_nm/meanBpExt_nm);
        end
    end


    % presence of tetramers not containing only As and Ts
    %  (since Netropsin might be expected to prevent YOYO-1 binding there,
    %    but might not be expected to beat out YOYO-1 everywhere else)
    wwwwMask = rand(barcodeLen_bps, 1) <= (2^4)/(4^4);
    
    bindingProbYOYO1 = not(wwwwMask);
    % % Breakdown of (still simplistic) approximation guiding binding
    % %  probability calculations:
    % wwwwUnbindedProb = 0.0;
    % nonwwwwUnbindedProb = 0.0;
    % 
    % wwwwBindingProbNetropsin = 1.0;
    % nonwwwwBindingProbNetropsin = 0.0;
    % 
    % wwwwBindingProbYOYO1 = 1.0 - wwwwBindingProbNetropsin - wwwwUnbindedProb;
    % nonwwwwBindingProbYOYO1 = 1.0 - nonwwwwBindingProbNetropsin - nonwwwwUnbindedProb;
    % 
    % bindingProbYOYO1 = (wwwwBindingProbYOYO1 * wwwwMask) + (nonwwwwBindingProbYOYO1 * not(wwwwMask));
    
    kernelNonzeroLen = round((8*meanBpsPerPsfSigmaWidth - 1)/2)*2 + 1; % round to nearest odd integer
    psfKernel = zeros(barcodeLen_bps, 1);
    psfKernel(ceil((barcodeLen_bps - kernelNonzeroLen)/2) + (1:kernelNonzeroLen)) = fspecial('gaussian', [1, kernelNonzeroLen], meanBpsPerPsfSigmaWidth);
    pseudoTheoryBarcode_bpRes = zscore(cconv(bindingProbYOYO1, fftshift(psfKernel), barcodeLen_bps));
    pseudoTheoryBarcode_pxRes = pseudoTheoryBarcode_bpRes(1:meanBpsPerPixel:end);
end