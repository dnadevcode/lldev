classdef ContigItem < handle
    % Contains information about a single contig and its states within
    % Assignment Contig Assembly
    %   Detailed explanation goes here
    
    properties
        name = '';
        seq = '';
        barcode
        barcodeLen = 0;
        isRemoved = false;
        removedTooShort = false;
        isRescaled = false;
        start = 0;
        stop = 0;
        flip = false;
        around = false;
        kbpsPerPixel = 0.6;
        
        cluster = 0;
        indexInCluster = 0;
        costList
        possibleSites
        
        gumbelCurveMu
        gumbelCurveBeta
    end
    
    methods
        function [contigItem] = ContigItem(contigName, ntSeq)
            %Constructor, not sure what to do with this one yet.
            contigItem.name = contigName;
            contigItem.seq = ntSeq;
        end
        
        function generate_barcode(contigItem, barcodeGenSettings, shortestPermissableSeq)
            
            % Takes a sequence and converts it into a barcode, using settings
            % specified in the object "settings"
            tfRemoveBecauseTooShort = contigItem.seqLen < shortestPermissableSeq;
            if tfRemoveBecauseTooShort
                contigItem.isRemoved = tfRemoveBecauseTooShort;
                contigItem.removedTooShort = tfRemoveBecauseTooShort;
                return
            end
            if length(contigItem.seq) <= 2*shortestPermissableSeq
                widthSigmasFromMean = 2;
            else
                widthSigmasFromMean = 4;
            end
            barcodeGenSettings.widthSigmasFromMean = widthSigmasFromMean;
            
            ntSeq = contigItem.seq;
            
            import CBT.Core.gen_unscaled_cbt_barcode;
            unscaledBarcode_pxRes = gen_unscaled_cbt_barcode(ntSeq, barcodeGenSettings);
            
            contigBarcode = unscaledBarcode_pxRes;
            contigItem.barcode = contigBarcode;
            contigItem.barcodeLen = length(contigItem.barcode);
            contigItem.kbpsPerPixel = length(contigItem.seq)/contigItem.barcodeLen;
        end
        
        function rescale(contigItem, globalMean, globalStd)
            % Rescales a contig's barcode, using global rescale parameters
            % mu and sigma, or just rescaling the barcode by itself by
            % leaving the input empty.
            if nargin < 2
                disp('jyypp')
                globalMean = mean(contigItem.barcode);
                globalStd = std(contigItem.barcode);
            elseif nargin < 3
                globalStd = std(contigItem.barcode);
            end
            if contigItem.isRemoved
                disp('Contig is removed, cannot be rescaled.')
            end
            
            contigItem.barcode = (contigItem.barcode-globalMean)/globalStd;
            contigItem.isRescaled = true;
        end
        
        function cost_lists_generation(contigItem, refCurve, numPlacementOptions, forcePlacementTF, removePvalue, pThreshold)
            
            %Generates a cost list for all possible ways that the
            %contig can be placed on the reference barcode (refCurve).
            if contigItem.isRemoved
                disp('Contig is removed, cost list cannot be calculated.')
                return
            end
            
            pTemp = ones(numPlacementOptions, 1);
            allPlacementChoiceIdxs = (1:numPlacementOptions)';
            
            import CBT.ExpComparison.Core.GrossCcorr.ccorr_all;
            [ccUnflipped, ccFlipped, flipTF] = ccorr_all(contigItem.barcode,refCurve,true,true);
            if flipTF
                [ccUnflipped, ccFlipped] = deal(ccFlipped, ccUnflipped);
            end
            
            refCurveLen = length(refCurve);
            idxRangeUnflipped = 1:refCurveLen;
            idxRangeFlipped = refCurveLen + idxRangeUnflipped;
            import CBT.ExpComparison.Core.calculate_p_value;
            pTemp(idxRangeUnflipped) = calculate_p_value(contigItem.gumbelCurveMu, contigItem.gumbelCurveBeta, ccUnflipped);
            pTemp(idxRangeFlipped) = calculate_p_value(contigItem.gumbelCurveMu, contigItem.gumbelCurveBeta, ccFlipped);
            if not(forcePlacementTF)
                pTemp(end) = removePvalue;
            end
            pTemp(pTemp < 10^-7) = 10^-7; %Remove possibility of pTemp almost being 0
            contigItem.costList = 2*log(pTemp);
            
            possibleSiteMask = pTemp < pThreshold;
            contigItem.possibleSites = allPlacementChoiceIdxs(possibleSiteMask);
            contigItem.costList(~possibleSiteMask) = 0;
            
            % Removes contigs that can only be not-placed
            if forcePlacementTF
                return
            else
                contigItem.isRemoved = length(contigItem.possibleSites) < 2;
            end
        end
        
        function remove_bad_sites(contigItem)
            % Removes sites that has a higher cost than the cost threshold,
            % in order to reduce the number of iterations that has to be
            % considered by the matching algorithm
            contigItem.costList = contigItem.costList(contigItem.possibleSites);
        end
    end
end

