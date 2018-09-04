function [theorySequenceFilepaths] = find_theory_filepaths_in_dirpath(dirpath)
        theorySequenceFilepaths = cell(0, 1);
        tmp = dir(dirpath);
        tmp = tmp(~[tmp.isdir] & ([tmp.bytes] > 0));
        theoryFilenames = {tmp.name};
        if not(isempty(theoryFilenames))
            theorySequenceFilepaths = fullfile(dirpath, theoryFilenames);
        end
end
