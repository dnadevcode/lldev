classdef ImageRetriever < handle
    % ImageRetriever - Class to retrieve images
    %
    % Authors:
    %  Saair Quaderi (SQ)
    
    properties (Access = private)
        ImageSrcList = {};
        ImageBayerPatterns = {};
    end
    
    methods
        function [ir] = ImageRetriever()
        end
        
        function [numImages] = get_image_count(ir)
            numImages = length(ir.ImageSrcList);
        end
        
        function [successTF, img] = retrieve_image(ir, imgIdx)
            imgSrc = ir.get_image_src(imgIdx);
            bayerPattern = ir.get_img_bayer_pattern(imgIdx);
            if isempty(bayerPattern)
                error('Bayer pattern for ''%s'' could not be detected', dngFilepath);
            end
            
            successTF = false;
            img = uint16(zeros(0,0,3));
            if ischar(imgSrc)
                [~, ~, fileExt] = fileparts(imgSrc);
                if strcmpi(fileExt, '.dng')
                    import ImgStab.import_dng;
                    img = import_dng(imgSrc);
                    successTF = true;
                end
            end
        end
        
        function [] = add_bayer_dngs(ir)
            sources = [];
            
            import ImgStab.prompt_dng_filepaths;
            newDngFilepaths = prompt_dng_filepaths(sources, true);
            newDngFilepaths = newDngFilepaths(:);
            import Microscopy.Import.get_dng_cfa_bayer_pattern;
            newBayerPatterns = cellfun(@get_dng_cfa_bayer_pattern, newDngFilepaths(:), 'UniformOutput', false);
            ir.ImageSrcList = [ir.ImageSrcList; newDngFilepaths];
            ir.ImageBayerPatterns = [ir.ImageBayerPatterns; newBayerPatterns];
        end
    end
    methods (Access = private)
        
        function [imgSrc] = get_image_src(ir, imgIdx)
            validateattributes(imgIdx, {'numeric'}, {'nonnegative', 'integer', '<=', ir.get_image_count()});
            imgSrc = ir.ImageSrcList{imgIdx};
        end
        
        function [bayerPattern] = get_img_bayer_pattern(ir, imgIdx)
            validateattributes(imgIdx, {'numeric'}, {'nonnegative', 'integer', '<=', ir.get_image_count()});
            bayerPattern = ir.ImageBayerPatterns{imgIdx};
        end
        
    end
end