function [ meltingMapTheoryBarcode_nmRes ] = convert_to_barcode_nmRes(doubleStrandProbs_bpRes, psfSigmaWidth_nm, bpLengthDoubleStrand_nm, bpLengthSingleStrand_nm)
    % CONVERT_TO_BARCODE_NMRES - converts to a nanometer-resolution
    %   prediction of melting map barcode based on provided unmelted
    %   probabilities at basepair resolution (and other parameters)
    %
    %  Note: channel confinement yields about a 61% reduction in length
    %   without taking melting into account so that should be 
    %   considered when specifiying basepair lengths in nm (those lengths
    %   are meant to represent extension length, not contour length)
    %
    %
    % Inputs:
    %   doubleStrandProbs_bpRes
    %     the probability that each basepair is double-stranded
    %     (unmelted)
    %   psfSigmaWidth_nm (optional; defaults to 300)
    %     the length in nm of a single deviation from the mean of the
    %     point spread function approximated as a gaussian
    %   bpLengthDoubleStrand_nm (optional; defaults to 0.332)
    %	  average extension length for a single basepair (double-stranded)
    %   bpLengthSingleStrand_nm (optional; defaults to 0.2855 = 0.332 * 0.86)
    %	  average extension length for a single basepair (single-stranded)
    %
    % Outputs:
    %   meltingMapTheoryBarcode_nmRes
    %     the stretched theory curve
    %
    % Authors:
    %   Charleston Noble
    %   Saair Quaderi (mostly refactoring/documentation/customizability)

    if nargin < 2
        psfSigmaWidth_nm = 300;
    end
    if nargin < 3
        bpLengthDoubleStrand_nm = 0.332;
    end
    if nargin < 4
        singleStrandReisnerExtensionCorrectionFactor = 0.86;
        bpLengthSingleStrand_nm = bpLengthDoubleStrand_nm * singleStrandReisnerExtensionCorrectionFactor;
    end

    % First, assume the DNA is not in a channel or melted or anything then
    % correct for this assumption


    doubleStrandProbs_bpRes = doubleStrandProbs_bpRes(:);
    theoryCurveLenBps = length(doubleStrandProbs_bpRes);
    barcodeBpLenNms = ones(theoryCurveLenBps, 1);

    % Take melting into account
    barcodeBpLocalStretchFactors = mtimes(...
        [doubleStrandProbs_bpRes, 1.0 - doubleStrandProbs_bpRes],...
        [bpLengthDoubleStrand_nm; bpLengthSingleStrand_nm]);
    barcodeBpLenNms = barcodeBpLenNms .* barcodeBpLocalStretchFactors;

    % Now take the cumulative sum to get an actual x-coordinate for each
    % base-pair
    stretchXVals = 1 + cumsum(barcodeBpLenNms) - barcodeBpLenNms(1);
    desiredXVals = 1:round(sum(barcodeBpLenNms));
    doubleStrandProbs_nmRes = interp1(stretchXVals, doubleStrandProbs_bpRes, desiredXVals);

    % Apply convolution with gaussian point spread function
    isLinearTF = true;
    widthSigmasFromMean = 3;
    import Microscopy.Simulate.Core.apply_point_spread_function;
    meltingMapTheoryBarcode_nmRes = apply_point_spread_function(doubleStrandProbs_nmRes, psfSigmaWidth_nm, isLinearTF, widthSigmasFromMean);
end