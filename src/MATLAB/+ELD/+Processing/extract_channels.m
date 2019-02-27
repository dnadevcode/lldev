function [ channelLabeling ] = extract_channels( rotatedAmp, sets )
    % extract channels
    %
    % :param rotatedAmp: input parameter.
	% :param sets: input parameter.

    % :returns: channelLabeling
    
    % rewritten by Albertas Dvirnas

   
    tmp_maxChannelIdxDiff = round((double(sets.channelDetection.channelWidthPx) - 1)/2);
    tmp_channelIdxDiffs = -tmp_maxChannelIdxDiff:tmp_maxChannelIdxDiff;
    
    % would it be more accurate to do this for frames separately and by
    % fitting a gaussian and then taking weighted values?
    [~, tmp_colIdx] = max(mean(mean(rotatedAmp,3),2));
    
    channelLabeling = zeros(size(rotatedAmp, 1), 1);
    try
        channelLabeling(tmp_colIdx + tmp_channelIdxDiffs) = 1;
    catch
        channelLabeling(max(1,tmp_colIdx + tmp_channelIdxDiffs(1)):min(length(channelLabeling),tmp_colIdx + tmp_channelIdxDiffs(end))) = 1;
        warning('Molecule is close to the edge, so the average is over less rows');
        
    end
    

end

