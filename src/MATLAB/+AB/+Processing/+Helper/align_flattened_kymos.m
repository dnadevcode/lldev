function [ flattenedKymosAligned, kymoMasksAligned, stretchFactorsMats, alignmentSuccessTFs] = align_flattened_kymos( tmp_numKymos, flattenedKymos, kymosMasks  )
    % align_flattened_kymos
    %
    % :param tmp_numKymos: input parameter.
    % :param flattenedKymos: input parameter.
    % :param kymosMasks: input parameter.

    % :returns: output
    
    % rewritten by Albertas Dvirnas
      
    flattenedKymosAligned = cell(tmp_numKymos, 1);
    kymoMasksAligned = cell(tmp_numKymos, 1);
    stretchFactorsMats = cell(tmp_numKymos, 1);
    skipPrealignTF = true;
    alignmentSuccessTFs = false(tmp_numKymos, 1);
    % forceEdgesTF = false;
    
    import OptMap.KymoAlignment.NRAlign.nralign;
    for tmp_kymoIdx = 1:tmp_numKymos
        tmp_flatKymo = flattenedKymos{tmp_kymoIdx};
        tmp_kymoMask = kymosMasks{tmp_kymoIdx};
        [tmp_alignedKymo, tmp_stretchFactorsMat, ~, tmp_alignedMask, ~, ~, tmp_alignmentSuccessTF] = nralign(tmp_flatKymo, skipPrealignTF, tmp_kymoMask);
        
        flattenedKymosAligned{tmp_kymoIdx} = tmp_alignedKymo;
        kymoMasksAligned{tmp_kymoIdx} = tmp_alignedMask;
        stretchFactorsMats{tmp_kymoIdx} = tmp_stretchFactorsMat;
        alignmentSuccessTFs(tmp_kymoIdx) = tmp_alignmentSuccessTF;
    end
    

end

