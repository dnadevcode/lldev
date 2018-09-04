function [alignedKymoBarcodesStretched, alignedKymoBitmasksStretched] = compare_consensus_vs_aligned_kymos(hParent, consensusFilepath, alignedKymoImgs, kymoNames)
    % COMPARE_CONSENSUS_VS_ALIGNED_KYMO - shows consensus va aligned kymos
    % 
    % Inputs:
    %    hParent: (optional, if empty treated as default)
    %       handle of the panel/figure in which to plot the results
    %       (new figure with panel generated if empty)
    %    consensusFilepath: (optional, if empty treated as default)
    %       filepath to the consensus mat file
    %       (prompted for file if empty)
    %    alignedKymoImgs: (optional, if empty treated as default)
    %       cell array of aligned kymo images (double matrices)
    %    kymoNames: (optional, if empty treated as default)
    %       cell array of display names for alignedKymoImgs,
    %       same number of alignedKymoImgs must be passed in if it is
    %       nonempty
    %
    %
    % Authors:
    %   Saair Quaderi
    
    alignedKymoBarcodesStretched = {};
    alignedKymoBitmasksStretched = {};
    if (nargin < 1) || isempty(hParent)
        hFig = figure('Name', 'Consensus - Kymo Barcode Alignment');
        hPanel = uipanel('Parent', hFig);
        hParent = hPanel;
    end
    if (nargin < 2) || isempty(consensusFilepath)
        import OptMap.DataImport.prompt_and_read_consensus_outputs;
        [aborted, consensusBarcodes, consensusBitmasks, consensusFilepaths] = prompt_and_read_consensus_outputs([], false);
        if aborted
            return;
        end
        consensusBarcode = consensusBarcodes{1};
        consensusBitmask = consensusBitmasks{1};
        consensusFilepath = consensusFilepaths{1};
        [~, consensusName, ~] = fileparts(consensusFilepath);
    else
        import OptMap.DataImport.import_consensus_outputs_from_file;
        [consensusBarcode, consensusBitmask] = import_consensus_outputs_from_file(consensusFilepath);
        [~, consensusName, ~] = fileparts(consensusFilepath);
    end
    if (nargin < 3) || isempty(alignedKymoImgs)
        if (nargin >= 4) && not(isempty(kymoNames))
            warning('Kymo names will be ignored since kymos were not passed in');
        end
        import CBT.ExpComparison.KymoComparison.Import.import_kymos;
        [alignedKymoImgs, ~, kymoNames] = import_kymos();
    elseif (nargin < 4)|| isempty(kymoNames)
        kymoNames = arrayfun(@(idx) sprintf('Kymo Barcode #%d', idx), 1:length(alignedKymoImgs));
    end
    consensusLen_px = length(consensusBarcode);
    
    
    import CBT.ExpComparison.KymoComparison.Core.gen_barcode_from_aligned_kymo;
    kymoBarcodes = cellfun(@gen_barcode_from_aligned_kymo, alignedKymoImgs, 'UniformOutput', false);
    kymoBarcodesStretched = cellfun(@(kymoBarcode) interp1(kymoBarcode, linspace(1, length(kymoBarcode), consensusLen_px)), kymoBarcodes, 'UniformOutput', false);
    kymoBitmasksStretched = cellfun(@(kymoBarcodeStretched) true(size(kymoBarcodeStretched)), kymoBarcodesStretched, 'UniformOutput', false);
    
    import CBT.Consensus.Core.calc_best_synced_orientation_similarity;
    bsosStructs = cellfun(...
            @(kymoBarcodeStretched, kymoBitmaskStretched) ...
                calc_best_synced_orientation_similarity(...
                    consensusBarcode, ...
                    kymoBarcodeStretched, ...
                    consensusBitmask, ...
                    kymoBitmaskStretched), ...
            kymoBarcodesStretched, kymoBitmasksStretched, ...
            'UniformOutput', false);
        
    import Barcoding.Reorienting.reorient_barcode_and_bitmask;
    [alignedKymoBarcodesStretched, alignedKymoBitmasksStretched] = cellfun(...
        @(kymoBarcodeStretched, kymoBitmaskStretched, bsosStruct) ...
            reorient_barcode_and_bitmask( ...
                kymoBarcodeStretched, ...
                kymoBitmaskStretched, ...
                bsosStruct.flipTFAtBest, ...
                bsosStruct.circShiftAtBest), ...
                kymoBarcodesStretched, kymoBitmasksStretched, bsosStructs,...
            'UniformOutput', false);
    
    
    hAxis = axes('Parent', hParent);
    
    import CBT.ExpComparison.KymoComparison.UI.plot_alignments;
    plot_alignments(hAxis, consensusName, consensusBarcode, consensusBitmask, kymoNames, alignedKymoBarcodesStretched, alignedKymoBitmasksStretched);
end