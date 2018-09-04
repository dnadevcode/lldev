function [alignedKymos, rawKymos, kymoNames] = import_kymos()
    [kymoFilenames, dirpath] = uigetfile('*.tif', 'Select Kymo Tiff File', 'Multiselect', 'on');
    aborted = isequal(dirpath, 0);
    if aborted
        alignedKymos = cell(0, 1);
        rawKymos = cell(0, 1);
        kymoNames = cell(0, 1);
        return;
    end
    if not(iscell(kymoFilenames))
        kymoFilenames = {kymoFilenames};
    end
    kymoFilepaths = fullfile(dirpath, kymoFilenames);
    rawKymos = cellfun(@(kymoFilepath) im2double(imread(kymoFilepath)), kymoFilepaths, 'UniformOutput', false);
    import OptMap.KymoAlignment.NRAlign.nralign;
    [alignedKymos] = cellfun(@(kymo) nralign(kymo), rawKymos, 'UniformOutput', false); % TODO: replace wpalign function
    [~, kymoNames, ~] = cellfun(@fileparts, kymoFilepaths, 'UniformOutput', false);
end