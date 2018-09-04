function [numericVect] = import_numeric_vector_from_textfile(promptTitle)
    [textFilename, dirpath] = uigetfile({'*.txt;'}, promptTitle, 'MultiSelect', 'off');
    if isequal(dirpath, 0)
        numericVect = [];
        return;
    end
    textFilepath = fullfile(dirpath, textFilename);
    fid = fopen(textFilepath, 'r');
    numericVect = fscanf(fid,'%f');
    fclose(fid);
    numericVect = numericVect';
end