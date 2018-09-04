function [errorMsg, data, seq] = validate_fasta_str(fastaFileStr, ignoreGapsTF, trimHeadersTF)
    if nargin < 2
        ignoreGapsTF = false;
    end
    if nargin < 3
        trimHeadersTF = false;
    end
    
    errorMsg = false;
    data = [];
    seq = [];
    ftext = textscan(fastaFileStr, '%s', 'delimiter', '\n');
    ftext = ftext{:};
    
    % Slightly modified version of code from Mastlab's fastaread function

    % it is possible that there will be multiple sequences
    commentLines = strncmp(ftext,'>',1);

    if ~any(commentLines)
        errorMsg = 'No fasta headers were found';
        return;
    end
    
    
    

    numSeqs = sum(commentLines);
    seqStarts = [find(commentLines); size(ftext,1)+1];
    data(numSeqs,1).Header = '';

    try
        for seqNum = 1:numSeqs
            % Check for > symbol ?
            data(seqNum).Header = ftext{seqStarts(seqNum)}(2:end);
            % convert 1x0 empty char array to ''; 
            if isempty(data(seqNum).Header) 
               data(seqNum).Header = ''; 
            end 

            firstRow = seqStarts(seqNum)+1;
            lastRow = seqStarts(seqNum+1)-1;
            numChars = cellfun('length',ftext(firstRow:lastRow));
            numSymbols = sum(numChars);
            data(seqNum).Sequence = repmat(' ',1,numSymbols);
            pos = 1;
            for rowNum=firstRow:lastRow
                str = strtrim(ftext{rowNum});
                len =  length(str);
                if len == 0
                    break
                end
                data(seqNum).Sequence(pos:pos+len-1) = str;
                pos = pos+len;
            end
            data(seqNum).Sequence = strtrim(data(seqNum).Sequence);
            if ignoreGapsTF
                data(seqNum).Sequence = strrep(data(seqNum).Sequence,'-','');
                data(seqNum).Sequence = strrep(data(seqNum).Sequence,'.','');
            end
        end

        % trim headers
        if trimHeadersTF
           for seqNum = 1:numSeqs
              data(seqNum).Header = sscanf(data(seqNum).Header,'%s',1);
           end
        end

        % in case of two outputs
        if nargout == 3
            if numSeqs == 1
                seq = data.Sequence;
                data = data.Header;
            else
                seq = {data(:).Sequence};
                data = {data(:).Header};
            end
        end

    catch allExceptions
        errorMsg = 'Incorrect data format in fasta file text';
        % error(message('bioinfo:fastaread:IncorrectDataFormat'))
        return;
    end

end