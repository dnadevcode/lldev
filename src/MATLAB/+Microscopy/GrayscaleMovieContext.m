classdef GrayscaleMovieContext < handle
    properties (Constant)
        Version = [0, 0, 1];
    end
    properties (SetAccess = private)
        ImportContext
        CropContext
    end
    methods
        function [gsMovC] = GrayscaleMovieContext(importItemContext, cropContext)
            validateattributes(importItemContext, {'Fancy.AppMgr.ImportItemContext'}, {'scalar'}, 1);
            validateattributes(cropContext, {'Microscopy.MovieCropping'}, {'scalar'}, 2);
            gsMovC.ImportContext = importItemContext;
            gsMovC.CropContext = cropContext;
        end
    end
end