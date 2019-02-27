classdef graymovie < handle
    properties (Constant)
        Version = [0, 0, 1];
    end
    properties(SetAccess = private)
        RawDataArr = [];
    end
    methods    
        function [gsMovObj] = graymovie(movie)
            gsMovObj.RawDataArr = movie;
        end
    
    end
end