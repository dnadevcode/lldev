classdef MovieCropping < handle
    properties (Constant)
        Version = [0, 0, 1];
    end
    properties (SetAccess = private)
        RowRange = [0 -1]
        ColRange = [0 -1]
        FrameRange = [0 -1]
    end
    methods
        function [movCropping] = MovieCropping(rowRange, colRange, frameRange)
            if (nargin < 3)
                frameRange = [1 1];
            end
            validateattributes(rowRange, {'numeric'}, {'nondecreasing', 'positive', 'integer', 'row', 'numel', 2}, 1);
            validateattributes(colRange, {'numeric'}, {'nondecreasing', 'positive', 'integer', 'row', 'numel', 2}, 2);
            validateattributes(frameRange, {'numeric'}, {'nondecreasing', 'positive', 'integer', 'row', 'numel', 2}, 3);
            movCropping.RowRange = rowRange;
            movCropping.ColRange = colRange;
            movCropping.FrameRange = frameRange;
        end
    end
end