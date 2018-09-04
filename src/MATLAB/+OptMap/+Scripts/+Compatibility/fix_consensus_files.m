function [ fixedConsensusStructs, xcorrs ] = fix_consensus_files(consensusFilepaths)
    % fix_consensus_files - fixes consensus files to use score based on
    %   length of barcodes instead of maximum sample size length of
    %   barcodes in a pair after cyclic permutations/flipping
    import SignalRegistration.Xcorr.masked_norm_xcorr_fft;
    
    if nargin < 1
        [filenameCells, filedirpath] = uigetfile({'*.mat'}, 'Consensus mat file(s)', 'MultiSelect','on');
        if isequal(filedirpath, 0)
            fixedConsensusStructs = {};
            xcorrs = [];
            return;
        else
            if not(iscell(filenameCells))
                filenameCells = {filenameCells};
            end
            consensusFilepaths = fullfile(filedirpath, filenameCells);
        end
    end
    getClusterBarcodeNums = @(keys) sort(cellfun(@(s) str2double(s), strsplit(strrep(strrep(keys,'[',''),']',''),',')));
    numFiles = length(consensusFilepaths);
    fixedConsensusStructs = cell(numFiles, 1);
    xcorrs = nan(numFiles, 1);
    import CBT.Consensus.Core.make_consensus_as_struct;
    import CBT.Consensus.Helper.extract_cluster_deliverables;
    for fileNum = 1:numFiles
        consensusFilepath = consensusFilepaths{fileNum};
        s = load(consensusFilepath);
        s = s.clusterConsensusData;
        oldClusterBarcodeNums = getClusterBarcodeNums(s.clusterKey); 
        consensusInputs = s.details.consensusStruct.inputs;
        barcodes = consensusInputs.barcodes;
        barcodeBitmasks = consensusInputs.barcodeBitmasks;
        barcodeAliases = consensusInputs.barcodeAliases;
        otherBarcodeData = [];
        if isfield(consensusInputs, 'otherBarcodeData')
            otherBarcodeData = consensusInputs.otherBarcodeData;
        end

        if isfield(consensusInputs ,'clusterThresholdScore')
            clusterThresholdScore = consensusInputs.clusterThresholdScore;
        elseif isfield(consensusInputs ,'clusterThresholdXcorr')
            clusterThresholdXcorr = consensusInputs.clusterThresholdXcorr;
            clusterThresholdScore = 0;
            if clusterThresholdXcorr > 0
                clusterThresholdScore = sqrt(length(barcodeBitmasks{1}))*clusterThresholdXcorr;
                fprintf('max length: %d\n', length(barcodeBitmasks{1}));
                warning(['xcorr threshold (', num2str(clusterThresholdXcorr), ') -> score threshold (', num2str(clusterThresholdScore), ')']);
            end
        else
            error('threshold missing');
        end
        newConsensusStruct = make_consensus_as_struct(barcodes, barcodeBitmasks, barcodeAliases, otherBarcodeData, clusterThresholdScore);
        newClusterBarcodeNumsCollection = cellfun(getClusterBarcodeNums, newConsensusStruct.clusterKeys, 'UniformOutput', false);
        idx = find(cellfun(@(newClusterBarcodeNums) isequal(oldClusterBarcodeNums, newClusterBarcodeNums), newClusterBarcodeNumsCollection));
        if isempty(idx)
            warning('TODO');
        else
            newClusterKey = newConsensusStruct.clusterKeys{idx};
            fprintf('%s\n', newClusterKey);
		    clusterConsensusData.clusterKey = newClusterKey;
			[...
				clusterConsensusData.barcode,...
				clusterConsensusData.bitmask,...
				clusterConsensusData.stdErrOfTheMean,...
				clusterConsensusData.indexWeights,...
				clusterConsensusData.clusterResultStruct,...
				~...
            ] = extract_cluster_deliverables(newConsensusStruct, newClusterKey);
		    clusterConsensusData.details.consensusStruct = newConsensusStruct;
            fixedConsensusStructs{fileNum} = clusterConsensusData;
            xcorrs(fileNum) = max(masked_norm_xcorr_fft(s.barcode(:), clusterConsensusData.barcode(:), s.bitmask(:), clusterConsensusData.bitmask(:), true));
            xcorrs(fileNum) = max(xcorrs(fileNum), max(masked_norm_xcorr_fft(s.barcode(:), flipud(clusterConsensusData.barcode(:)), s.bitmask(:), flipud(clusterConsensusData.bitmask(:)), true)));
            
            [consensusDirpath, consensusFilename, fileExt] = fileparts(consensusFilepath);
            consensusDirpathOut = fullfile(consensusDirpath, 'fixed');
            import Fancy.IO.mkdirp;
            mkdirp(consensusDirpathOut);
            consensusFilepathOut = fullfile(consensusDirpathOut, [consensusFilename, '-fixed', fileExt]);
            save(consensusFilepathOut, 'clusterConsensusData');
        end
    end
end

