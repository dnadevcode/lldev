function [pixelWidth_nm] = calc_image_pixel_width(cameraPixelWidth_microns, objectiveMag, lensMag, cMountMag, binning)

    
    validateattributes(cameraPixelWidth_microns, {'numeric'}, {'positive', 'finite'}, 1);
    
    validateattributes(objectiveMag, {'numeric'}, {'positive', 'finite'}, 2);
    
    if (nargin < 5) || isempty(binning)
        import Microscopy.get_camera_defaults;
        camDefaults = get_camera_defaults();
        binning = camDefaults.binning;

        if (nargin < 4) || isempty(cMountMag)
            cMountMag = camDefaults.cMountMag; % Usually 1
        else
            validateattributes(cMountMag, {'numeric'}, {'positive', 'finite'}, 4);
        end
        
        if (nargin < 3) || isempty(lensMag)
            lensMag = camDefaults.lensMag;
        else
            validateattributes(lensMag, {'numeric'}, {'positive', 'finite'}, 3);
        end
    else
        validateattributes(binning, {'numeric'}, {'positive', 'integer'}, 5);
    end
    

    nmsPerMicron = 1e3;
    pixelWidth_nm = nmsPerMicron * (cameraPixelWidth_microns * binning)/(objectiveMag * lensMag * cMountMag);
    % cameraPixelWidth_microns: (e.g. 16 or 13)
    % objectiveMag: (e.g. 100 {as in 100x} or 63)
    % lensMag: (e.g. 1 {as in 1x} or alternatively 1.25, 1.6 or 2)
    % cMountMag: (e.g 1 {as in 1x} -- usually just 1)
    % binning: (e.g 1 {as in 1x1} or alternatively 2 or 4) -
    %     binning means NxN pixels are clustered together into single
    %      pixels by summing charge packets, this is typically done
    %      to improve signal to noise ratio since it reduces the read
    %      noise level (dark current noise is unaffected) and/or to
    %      improve the frame rate, but binning comes at the expense of
    %      spacial resolution
    
end