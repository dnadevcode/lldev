classdef DataItem < handle
    % DATAITEM - Data Item
    
    properties
        Value
    end
    
    methods
        function [di] = DataItem(value)
            di.Value = value;
        end
    end
end

