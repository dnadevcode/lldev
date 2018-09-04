function [aborted, filepaths] = prompt_for_filepaths(filterSpec, selectionWindowTitle, allowMultiselect)
    % PROMPT_FOR_FILEPATHS
    %
    % Inputs:
    %   filterSpec
    %     filter specifications for files to be chosen
    %     See documentation of the FilterSpec parameter of uigetfile for
    %     details
    %   selectionWindowTitle
    %     A string specifying the title for the file selection dialog
    %   allowMultiselect (optional, defaults to true)
    %     Whether multiple files may be selected
    %     (Note that files may have to be in the same directory to be
    %     selected)
    %
    % Outputs:
    %   aborted
    %     true if no filepaths were selected, and false otherwise
    %   filepaths
    %     cell array of selected filepaths as strings
    %
    % Authors:
    %   Saair Quaderi
    
    if nargin < 3
        allowMultiselect = true;
    else
        validateattributes(allowMultiselect, {'logical'}, {'scalar'}, 3);
    end
    if allowMultiselect
        multiselect = 'on';
    else
        multiselect = 'off';
    end
    if (nargin < 2)
        if (allowMultiselect)
            selectionWindowTitle = 'Select file(s)';
        else
            selectionWindowTitle = 'Select file';
        end
    end
    
    [filenames, filedirpath] = uigetfile(filterSpec, selectionWindowTitle, 'MultiSelect',multiselect);
    aborted = isequal(filedirpath, 0);
    if aborted
        filepaths = cell(0, 1);
    else
        if not(iscell(filenames))
            filenames = { filenames };
        end
        filenames = filenames(:);
        filepaths = fullfile(filedirpath, filenames);
    end
end