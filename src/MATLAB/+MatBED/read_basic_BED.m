function [filesHasError, fileContents] = read_basic_BED()
%READ_BASIC_BED Summary of this function goes here
%   Detailed explanation goes here

    function [isHeaderLine, headerLineType] = is_header_line(strLine)
        headerLineStartStrs = {'#'; 'browser'; 'track'};
        isHeaderLine = false;
        headerLineType = 'n/a';
        strLineLen = length(strLine);
        numHeaderLineStartTypes = length(headerLineStartStrs);
        for headerLineStartTypeNum = 1:numHeaderLineStartTypes
            headerLineStart = headerLineStartStrs{headerLineStartTypeNum};
            headerLineStartLen = length(headerLineStart);
            if (strLineLen >= headerLineStartLen) && strcmp(strLine(1:headerLineStartLen), headerLineStart)
                 isHeaderLine = true;
                 headerLineType = headerLineStart;
            end
        end
    end

    function [filepathsBED] = get_BED_filepaths()
        [filenames, dirpath] = uigetfile({'*.bed'},'Select BED files', 'Multiselect', 'on');
        if isequal(dirpath, 0)
            filepathsBED = cell(0, 1);
            return;
        end
        if not(iscell(filenames))
            filenames = {filenames};
        end
        filepathsBED = fullfile(dirpath, filenames);
    end

    function [filesHasError, fileContents] = get_BED_data(filepathsBED)
        filepathsBED = filepathsBED(:);
        numFilepaths = length(filepathsBED);
        filesHasError = false(numFilepaths, 1);
        fileErrMsgs = cell(numFilepaths, 1);
        filesHeaderLines = cell(numFilepaths, 1);
        filesBodyTables = cell(numFilepaths, 1);
        for filepathNum=1:numFilepaths
            filepath = filepathsBED{filepathNum};
            fid = fopen(filepath, 'r');
            fileLines = textscan(fid,'%s','Delimiter','\n');
            fileLines = fileLines{1};
            fclose(fid);
            
            numLines = length(fileLines);
            inHeader = true;
            lineNum = 1;
            while inHeader && (lineNum <= numLines)
                strLine = fileLines{lineNum};
                [isHeaderLine, headerLineType] = is_header_line(strLine);
                inHeader = isHeaderLine;
                lineNum = lineNum + 1;
            end
            headerLines = fileLines(1:(lineNum - 1));
            bodyLines = fileLines(lineNum:end);
            
            fieldEntriesStrs = regexp(bodyLines, {'\s'}, 'split');
            numFieldsInLines = cellfun(@length, fieldEntriesStrs);
            numFields = numFieldsInLines(1);
            errMsg = [];
            chrom = cell(0, 1);
            chromStarts = NaN(0, 1);
            chromEnds = NaN(0, 1);
            if numFields < 3
                errMsg = 'Missing required fields';
            elseif any(numFields ~= numFieldsInLines)
                errMsg = 'Inconsisent number of fields';
            elseif numFields > 3
                errMsg = 'This program does not yet support more than the three required fields';
            else
                fieldEntriesStrs = vertcat(fieldEntriesStrs{:});
                fieldEntries = fieldEntriesStrs;
                chrom = fieldEntries(:, 1);
                fieldEntries(:, 2) = cellfun(@(chromStartStr) uint64(str2double(chromStartStr)), fieldEntriesStrs(:, 2), 'UniformOutput', false);
                if  not(isequal(fieldEntriesStrs(:, 2), cellfun(@num2str, fieldEntries(:, 2), 'UniformOutput', false)))
                    errMsg = 'Invalid entries for chromStart';
                else
                    fieldEntries(:, 3) = cellfun(@(chromEndStr) uint64(str2double(chromEndStr)), fieldEntriesStrs(:, 3), 'UniformOutput', false);
                    if  not(isequal(fieldEntriesStrs(:, 3), cellfun(@num2str, fieldEntries(:, 3), 'UniformOutput', false)))
                        errMsg = 'Invalid entries for chromEnd';
                    else

                        chromStarts = cell2mat(fieldEntries(:, 2));
                        chromEnds = cell2mat(fieldEntries(:, 3));

                        if any(chromEnds <= chromStarts)
                            chrom = cell(0, 1);
                            chromStarts = NaN(0, 1);
                            chromEnds = NaN(0, 1);
                            errMsg = 'Inconsistency between entries for chromStart and chromEnd';
                        end
                        
                        if any(chromEnds >= uint64(flintmax('double')))
                            errMsg = ['This program does not support integer values larger than ', num2str(flintmax('double') - 1)];
                        end
                    end
                end
            end
            
            filesHasError(filepathNum) = not(isempty(errMsg));
            fileErrMsgs{filepathNum} = errMsg;
            filesHeaderLines{filepathNum} = headerLines;
            
            fileBodyTable = table(chrom, chromStarts, chromEnds, 'VariableNames',{'chrom', 'chromStarts', 'chromEnds'});
            filesBodyTables{filepathNum} = fileBodyTable;
        end
        fileContents= table(...
            filepathsBED,...
            fileErrMsgs,...
            filesHeaderLines,...
            filesBodyTables,...
            'VariableNames',...
            {'filepath'; 'errMsgs'; 'headerLines'; 'bodyData'});
        
    end

    [filepathsBED] = get_BED_filepaths();
    [filesHasError, fileContents] = get_BED_data(filepathsBED);
end

