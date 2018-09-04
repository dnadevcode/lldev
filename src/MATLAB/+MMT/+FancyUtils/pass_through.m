function [ varargout ] = pass_through( varargin )
    %PASS_THROUGH - Passes any input arguments out as outputs
    %   and empty matrices for outputs which have no correspending
    %   input (where nargin < nargout)
    varargout(1:nargout) = cell(nargout,1);
    varargout(1:min(nargin, nargout)) = varargin(1:min(nargin, nargout));
end

