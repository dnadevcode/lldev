function [aborted, unscaledContigBarcode, contigSeqFilepath] = try_prompt_single_unscaled_contig_barcode()
    import CA.Old.Core.gen_unscaled_barcodes;

    [contigSeqFilename, contigSeqDirpath] = uigetfile({'*'}, 'Please provide the contig sequence to place', 'MultiSelect', 'off');
    aborted = isequal(contigSeqDirpath, 0);
    if aborted
        unscaledContigBarcode = [];
        contigSeqFilepath = '';
        return;
    end
    contigSeqFilepath = fullfile(contigSeqDirpath, contigSeqFilename);
    unscaledContigBarcodes = gen_unscaled_barcodes({contigSeqFilepath});
    unscaledContigBarcode = unscaledContigBarcodes{1};
end