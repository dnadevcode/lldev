function [reorientedBayerPattern, unorientedBayerPattern, dngCurrOrientation] = get_dng_cfa_bayer_pattern(dngFilepath)
    reorientedBayerPattern = [];
    if nargin < 1
        validFileExts = '*.dng; *.DNG';
        sourcePath = pwd();
        [dngFilename, dirpath] = uigetfile(validFileExts, 'Select dng', sourcePath);
        if dirpath == 0
            return;
        end
        dngFilepath = fullfile(dirpath, dngFilename);
    end
    
    tagCode_CFAPattern = 33422;
    % Note:
    %  Relevant tifftag information can be found here:
    %   https://web.archive.org/web/20170503130822/https://www.loc.gov/preservation/digital/formats/content/tiff_tags.shtml
    %   https://web.archive.org/web/20170115203304/http://www.awaresystems.be/imaging/tiff/tifftags/privateifd/exif/cfapattern.html
    %   https://web.archive.org/web/20170115122110/http://awaresystems.be/imaging/tiff/tifftags/orientation.html
    
    dngInfo = imfinfo(dngFilepath);
    imgInfo = dngInfo.SubIFDs{1};
    unorientedBayerPattern = [imgInfo.UnknownTags([imgInfo.UnknownTags.ID] == tagCode_CFAPattern).Value];
    unorientedBayerPattern = [unorientedBayerPattern(1:2); unorientedBayerPattern(3:4)];
    
    
    stdOrientation = 1; % Visual top of image is first row, Visual left of image is first column
    dngCurrOrientation = dngInfo.Orientation;
    % Orientation Keys Visual Corner Idxs:
    %  1: TOP LEFT
    %  2: TOP RIGHT
    %  3: BOTTOM LEFT
    %  4: BOTTOM RIGHT
    
    orientationCornerMappings = {
        [1, 2; 3, 4], ...
        [2, 1; 4, 3], ...
        [4, 3; 2, 1], ...
        [3, 4; 1, 2], ...
        [1, 3; 2, 4], ...
        [2, 4; 1, 3], ...
        [4, 2; 3, 1], ...
        [3, 1; 4, 2] ...
    };
    
    currCornerMapping = orientationCornerMappings{dngCurrOrientation};
    reorientedBayerPattern = arrayfun(@(visualCornerIdx) unorientedBayerPattern(currCornerMapping == visualCornerIdx), orientationCornerMappings{stdOrientation});
    % bayerPattern = [unorientedBayerPattern(orientationKey == 1), unorientedBayerPattern(orientationKey == 2); unorientedBayerPattern(orientationKey == 3), unorientedBayerPattern(orientationKey == 4)];
    rgbstring = 'rgb';
    unorientedBayerPattern = rgbstring([unorientedBayerPattern(1, 1:2), unorientedBayerPattern(2, 1:2)] + 1);
    reorientedBayerPattern = rgbstring([reorientedBayerPattern(1, 1:2), reorientedBayerPattern(2, 1:2)] + 1);
end