function [dataTable, originalColHeaders] = tsvStr2table(tsvStr, hasHeaderline)
    % Inputs:
    %  tsvStr
    %   the string containing the contents of a tsv file
    %  hasHeaderline
    %   whether the first line should be treated as column headers
    %
    % Outputs:
    %  dataTable
    %    the table of data in the tsv
    %  originalColHeaders
    %    the original column headers for the data (since Matlab's table
    %    only supports unique valid matlab variable names as column
    %    headers in the table and the headers need to be updated to meet 
    %    the validation criteria)
    
    carriageReturnChar = sprintf('\r');
    newlineChar = sprintf('\n');
    tabChar = sprintf('\t');
    tsvStr = strrep(strrep(tsvStr, carriageReturnChar, newlineChar), [newlineChar, newlineChar], newlineChar);
    strLines = strsplit(tsvStr, newlineChar);
    lineEntries = cellfun(@(rowStr) strsplit(rowStr, tabChar), strLines, 'UniformOutput', false);
    numLineEntries = cellfun(@(rowEntries) numel(rowEntries), lineEntries);
    emptyLines = arrayfun(@(rowIdx) (numLineEntries(rowIdx) == 0) || ((numLineEntries(rowIdx) == 1) && isempty(lineEntries{rowIdx}{1})), 1:numel(numLineEntries));
    lineEntries = lineEntries(~emptyLines);
    numLineEntries = numLineEntries(~emptyLines);
    maxNumRowEntries = max(numLineEntries);
    linesWithMissingEntries = find(numLineEntries < maxNumRowEntries);
    if any(linesWithMissingEntries)
        warning(['Missing tab-delimited entries in ', num2str(numel(linesWithMissingEntries)), 'lines']);
    end
    lineEntries(linesWithMissingEntries) = cellfun(@(c) [c, cell(maxNumRowEntries - numel(c), 1)], lineEntries(linesWithMissingEntries), 'UniformOutput', false);
    lineEntries = vertcat(lineEntries{:});
    if hasHeaderline
        originalColHeaders = lineEntries(1,:);
        matlabVarFriendlyColHeaders = matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(originalColHeaders));
        lineEntries = lineEntries(2:end,:);
    else
        originalColHeaders = cell(maxNumRowEntries, 1);
        matlabVarFriendlyColHeaders = strcat({'Column_'}, num2str((1:maxNumRowEntries)'));
    end
    dataTable = cell2table(lineEntries,...
        'VariableNames', matlabVarFriendlyColHeaders...
       );
end