function [eCISs3] = reproduce_eCISs3(tableColRatiosAT, numTrials, genSequenceLen, barcodeGenSettings)
    % THIS FUNCTION IS NOT READY TO BE USED. IT IS A DRAFT.
    %
    % Note from SQ: Erik's code that produced eCISs3.mat is
    %   nowhere to be found in the repository.
    %  (I have no idea what eCISs3 evens stands for.)
    % The code below is an incomplete attempt at producing data
    %  that is similar to eCISs3
    %
    % You can find eCISs3.mat in SVN R53 in
    %   the path MeltCB/svn/InputFiles/eCISs3.mat
    import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;

    numRatios = numel(tableColRatiosAT);

    eCISs3 = NaN(numTrials, numRatios);
    
    for ratioNum=1:numRatios
        tmpRatioAT = tableColRatiosAT(ratioNum);
        tmpNTCounts.AT = round(genSequenceLen*tmpRatioAT);
        tmpNTCounts.CG = sequenceLength - tmpNTCounts.AT;
        tmpNTCounts.A = round(tmpNTCounts.AT/2);
        tmpNTCounts.T = tmpNTCounts.AT - tmpNTCounts.A;
        tmpNTCounts.C = round(tmpNTCounts.CG/2);
        tmpNTCounts.G = tmpNTCounts.CG - tmpNTCounts.C;
        ntIntLookupStr = 'ACGT';
        tmpSeqOrdered = int2nt([...
            repmat(strfind(ntIntLookupStr, 'A'), [1, tmpNTCounts.A]),...
            repmat(strfind(ntIntLookupStr, 'C'), [1, tmpNTCounts.C]),...
            repmat(strfind(ntIntLookupStr, 'G'), [1, tmpNTCounts.G]),...
            repmat(strfind(ntIntLookupStr, 'T'), [1, tmpNTCounts.T])...
        ]);
        for trialNum=1:numTrials
            [~, rndOrdering] = sort(rand(size(tmpSeqOrdered)));
            tmpSeq = tmpSeqOrdered(rndOrdering);
            tmpCurve = cb_netropsin_vs_yoyo1_plasmid(tmpSeq, barcodeGenSettings.concNetropsin_molar, barcodeGenSettings.concYOYO1_molar, [], true);
            % TODO: curve post-processing (unknown process)
            %   PSF convolution? (if so, with what width?)
            %   reisner rescaling?
            %   bp to pixel resolution conversion? (if so, with what bpsPerPixel?)
            error('This code is still just a work in progress'); % remove when complete

            tmpCurveStd = std(tmpCurve);
            eCISs3(trialNum, ratioNum) = tmpCurveStd;
        end
    end
end
