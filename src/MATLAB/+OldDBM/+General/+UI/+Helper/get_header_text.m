function [headerText] = get_header_text(fileIdx, fileMoleculeIdx, filename)
    % if filename contains a space, chop off anything preceding the last space in the filename
    headerText = textscan(filename, '%s');
    headerText = headerText{1};
    headerText = headerText{end};

    headerText = sprintf('%s\n%d_%d', headerText, fileIdx, fileMoleculeIdx);
end