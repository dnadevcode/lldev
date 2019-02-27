function kymo = import_tiff_img()
    [kymoFilename, dirpath] = uigetfile('*.tif', 'Select Kymo Tiff File', 'Multiselect', 'off');
    aborted = isequal(dirpath, 0);
    if aborted
        return;
    end
    kymoFilepath = fullfile(dirpath, kymoFilename);
    kymo = double(imread(kymoFilepath));
end