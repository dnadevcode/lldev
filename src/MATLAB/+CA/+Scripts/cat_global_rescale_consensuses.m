function [] = cat_global_rescale_consensuses()
    % Rescales many barcodes at the same time and then saves the barcodes
    % individually. (bad practices are used) 
    disp('Running hacky rescaling script (current implementation is not good practice)')

    import OptMap.DataImport.prompt_and_read_consensus_outputs;

    [~, consensusBarcodes, consensusBitmasks, consensusFilepaths] = prompt_and_read_consensus_outputs();

    if isempty(consensusBarcodes)
        disp('No consensus, or contig, file was selected');
        return;
    end

    % currently actual consensus bitmasks are replaced such that any 0s are made 1s
    % TODO: actually respect the real bitmasks throughout contig assembly code
    consensusBitmasks = cellfun(@(consensusBitmask) true(size(consensusBitmask)), consensusBitmasks, 'UniformOutput', false);

    % Get mean and deviation of all barcode values
    allBarcodeVals = horzcat(consensusBarcodes{:});
    allBitmaskVals = horzcat(consensusBitmasks{:});
    meanAll = nanmean(allBarcodeVals(allBitmaskVals));
    stdAll = nanstd(allBarcodeVals(allBitmaskVals));

    % Rescale all the barcodes
    barcodesRescaled = cellfun(@(barcode) ((barcode - meanAll)./stdAll), consensusBarcodes, 'UniformOutput', false);


    [dirpaths, importedFilenames] = cellfun(@fileparts, consensusFilepaths, 'UniformOutput', false);
    rescaledFilesSuffix = '_rescaled';
    rescaledFilesExt = '.mat';
    rescaledFilepaths = cellfun(...
        @(dirpath, importedFilename) ...
            fullfile(dirpath, [importedFilename, rescaledFilesSuffix, rescaledFilesExt]), ...
            dirpaths, importedFilenames, ...
            'UniformOutput', false);

    % Save barcodes
    numBarcodes = length(barcodesRescaled);
    for barcodeNum = 1:numBarcodes
        % TODO: stop creating these bad/bastardized
        %  pseudo-consensus files (create a new format to import
        %  for this purpose or something like that instead)
        % this is bad practice
        clusterConsensusData = struct(...
            'barcode', barcodesRescaled{barcodeNum}, ...
            'bitmask', consensusBitmasks{barcodeNum} ...
            ); %#ok<NASGU>
        save(rescaledFilepaths{barcodeNum}, 'clusterConsensusData');
    end
end