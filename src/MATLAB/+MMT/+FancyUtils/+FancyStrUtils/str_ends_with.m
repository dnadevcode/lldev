function [tfEndsWith] = str_ends_with(mainStr, suffixStr)
    % STR_ENDS_WITH - returns true if the string ends with the suffix
    %   provided
    %
    % Inputs:
    %   mainStr
    %     the main string
    %   suffix
    %     the suffix string
    %
    % Outputs:
    %   tfEndsWith
    %     true if the main string ends with the suffix string and false
    %     otherwise
    %
    % Authors:
    %   Saair Quaderi
    
    suffixLen = length(suffixStr);
    if length(mainStr) < suffixLen
        tfEndsWith =  false;
    else
        tfEndsWith = strcmp(mainStr(end-suffixLen+1:end), suffixStr);
    end
end