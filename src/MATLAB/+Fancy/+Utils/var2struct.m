function [structOut] = var2struct(varargin)
    % VAR2STRUCT - creates a struct out of the provided variables ysing the
    %   actual names of the variables as passed as the field names for the
    %   struct
    %   *****************************************************
    %    ONLY USE THIS IF YOU WANT CHANGED VARIABLE NAMES IN
    %            CALLING FUNCTION TO CHANGE RESULTS!
    %   ******************************************************
    %
    %  Inputs:
    %   (variable/unspecified so they may be dynamically determined)
    %
    %  Outpus:
    %    structOut
    %      a 1x1 struct with fields which are the same as the names of the
    %      variables passed in by the calling function and values are the
    %      values of these inputs
    names = arrayfun(@inputname,1:nargin,'UniformOutput',false);
    structOut = cell2struct(varargin,names,2);
end