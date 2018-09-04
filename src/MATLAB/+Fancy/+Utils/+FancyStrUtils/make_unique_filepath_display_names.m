function [displayNames] = make_unique_filepath_display_names(filepaths)
        if isempty(filepaths)
            displayNames = filepaths;
            return;
        end
        if length(unique(filepaths)) < length(filepaths)
            error('Filepaths provided were not unique');
        end
        [~, filenamesSansExt, fileExts] = cellfun(...
            @fileparts, ...
            filepaths, ...
            'UniformOutput', false);
        filenames = strcat(filenamesSansExt, fileExts);
        [uniqueFilenames, ~, uniqueFilenameIdxs] = unique(filenames);
        
        displayNames = filepaths;
        for uniqueFilenameIdx = 1:max(uniqueFilenameIdxs)
            filepathsMask = (uniqueFilenameIdx == uniqueFilenameIdxs);
            
            if (sum(filepathsMask) < 2)
                uniqueFilename = uniqueFilenames{find(filepathsMask, 1)};
                displayNames(filepathsMask) = {uniqueFilename};
            end
        end
end