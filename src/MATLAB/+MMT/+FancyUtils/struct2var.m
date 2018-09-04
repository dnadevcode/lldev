function [] = struct2var(structIn)
    % STRUCT2VAR - for every field in each input struct, a variable in the
    %   base workspace is created with the variable name set to the field
    %   name and the value set to the value in the struct
    %
    %  Inputs:
    %    a 1x1 struct with miscellaneous fields that you want to be set as
    %    variables in the base workspace
    %
    %  Side Effects:
    %    the base workspace has some variables assigned in it with the
    %    variable names determined by the field names for the input struct
    
    cellfun(@(n, v) assignin('base', n, v), fieldnames(structIn), struct2cell(structIn));

    % To create variables in a workspace other than the base, you would have
    % to directly run the code above, replacing "base" with "caller" within 
    % the actual workspace
end