function [ kthOutput ] = kth_output(kn, fn, varargin)
    % KTH_OUTPUT - returns the kth output for the function when provided
    % the inputs specified in varargin
    %
    % Inputs:
    %   kn
    %     has value of [k n] specifying the indices k and n hwere n is the
    %     nargout the function sees and k is the index of the actual
    %     output desired
    %     if n = k (as may be quite likely), simply one value may be
    %     provided in kn and both n and k will be set to it
    %   fn
    %     the handle of the function to be called
    %   varargin (variable number of additional inputs)
    %     any inputs that should be passed along to fn
    %
    % Outputs:
    %   kthOutput
    %     the kth output the function returns when provided the specified
    %     input and provided a nargout of n
    %
    % Authors:
    %   Saair Quaderi
    
    validateattributes(kn, {'numeric'}, {'positive', 'integer', 'nondecreasing'});
    if numel(kn) == 2
        k = kn(1);
        n = kn(2);
    elseif numel(kn) == 1
        k = kn;
        n = kn;
    else
        error('First input must contain either one [k] (n = k implied) or two [k n] index values at most');
    end
    nOutputs = cell(n, 1);
    [nOutputs{1:n}] = fn(varargin{:});
    kthOutput = nOutputs{k};
end
