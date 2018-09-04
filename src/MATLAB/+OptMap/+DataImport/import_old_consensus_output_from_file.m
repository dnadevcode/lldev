function [consensusBarcode] = import_old_consensus_output_from_file(oldConsensusFilepath)
    fid = fopen(oldConsensusFilepath,'rt');
    tline = fgets(fid);
    while length(tline) < 11 || (~strcmp(tline(1:11),'# consensus') && ~strcmp(tline(1:10),'#   theory'))
        tline = fgets(fid);
    end
    if strcmp(tline(1:11),'# consensus')
        secondCol = false;
    else
        secondCol = true;
    end
    p = 1;
    numb = char(zeros(1,6));
    consensusBarcode = zeros(1,500);
    tline = fgets(fid);
    while ischar(tline)
        j = 1;
        while strcmp(tline(j),' ')
            j = j + 1;
        end
        k = 1;
        if secondCol
            while ~strcmp(tline(j),' ')
                j = j + 1;
            end
            while strcmp(tline(j),' ')
                j = j + 1;
            end
        end
        while ~strcmp(tline(j),' ')
            numb(k) = tline(j);
            k = k + 1;
            j = j + 1;
        end
        consensusBarcode(p) = str2double(numb);
        p = p + 1;
        tline = fgets(fid);
    end
    consensusBarcode(consensusBarcode == 0) = [];
    fclose(fid);
end