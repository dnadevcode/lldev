function [] = export_contig_placements_txt(dataSampleName, refBarcode, refContigPlacementValsMat, meanBpExt_pixels, sVal, numTotalOverlap, excludedContigsStr)
    if nargin < 5
        sVal = [];
    end
    if nargin < 6
        numTotalOverlap = [];
    end
    if nargin < 7
        excludedContigsStr = [];
    end

    meanKbpExt_pixels = meanBpExt_pixels * 1000;
    kbpsPerPixel = 1/meanKbpExt_pixels;
    
    timestamp = datestr(clock(), 'yyyy-mm-dd HH:MM:SS');
    [outTxtFilename, outTxtDirpath] = uiputfile('*.txt', 'Save As');
    outTxtFilepath = fullfile(outTxtDirpath, outTxtFilename);
    fid = fopen(outTxtFilepath, 'w');
    % Header
    fprintf(fid, '#Experiment: %s\n', dataSampleName);
    fprintf(fid, '#Date: %s\n', timestamp);
    if not(isempty(sVal))
        fprintf(fid, '#S-value: %g\n', sVal);
    end
    if not(isempty(numTotalOverlap))
        fprintf(fid, '#Overlap: %s\n', num2str(numTotalOverlap));
    end
    if not(isempty(excludedContigsStr) && not(ischar([])))
        fprintf(fid, '#Contigs excluded: %s\n', excludedContigsStr);
    end
    fprintf(fid, '#\n');
    % Titles
    fprintf(fid, '#x-pos bp\tExperiment\t');
    refBarcodeLen = length(refBarcode);
    numPlacedContigs = size(refContigPlacementValsMat, 2);
    paddedContigsMat = refContigPlacementValsMat;
    paddedContigsMat(isnan(paddedContigsMat)) = 0; %TODO: check if this is necessary? remove?
    fprintf(fid,'\n');
    % Values
    xPos_Kbps = round(linspace(0, round(refBarcodeLen * kbpsPerPixel), refBarcodeLen));
    for refPixelIdx = 1:refBarcodeLen
        fprintf(fid, '%8.0f\t', xPos_Kbps(refPixelIdx));
        fprintf(fid, '%7.6f\t', refBarcode(refPixelIdx));
        for placedContigNum = 1:numPlacedContigs
            fprintf(fid, '%7.6f\t', paddedContigsMat(refPixelIdx, placedContigNum));
        end
        fprintf(fid,'\n');
    end
    fclose(fid);
end