function [] = export_single_contig_placement_txt(placedContigBarcode, rescaledConcensusBarcode, consensusBarcodeName)
    pprep = NaN(size(rescaledConcensusBarcode));
    pprep(1:length(placedContigBarcode)) = placedContigBarcode;


    titleStr = sprintf('Save %s As', consensusBarcodeName);

    [outputTxtFilename, dirpath] = uiputfile('*.txt', titleStr);
    if isequal(dirpath, 0)
        return;
    end
    outputTxtFilepath = fullfile(dirpath, outputTxtFilename);
    fid = fopen(outputTxtFilepath, 'wt');
    fprintf(fid,'Matching contigs on %s:\n',consensusBarcodeName);
    for pixelIdx=1:length(rescaledConcensusBarcode)
        fprintf(fid,'%f %f\n', rescaledConcensusBarcode(pixelIdx), pprep(pixelIdx));
    end
    fclose(fid);
end