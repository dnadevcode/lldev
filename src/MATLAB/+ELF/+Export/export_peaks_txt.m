function [] = export_peaks_txt(txtFilepathPeaks, probGoodFit, peakPositionsVect, peakAreasVect, psfSigmaWidth_pixels, areaOnePeak, meanBackgroundNoise, x, unitsPerPixel, unitStr)
    numPeaks = length(peakPositionsVect);
    for peakIdx = 1:numPeaks
        peakPos = peakPositionsVect(peakIdx);
        peakArea = peakAreasVect(peakIdx);
        gMembFnMat = gaussmf(x, [psfSigmaWidth_pixels, peakPos]); %   GAUSSMF(X, [SIGMA, C]) = EXP(-(X - C).^2/(2*SIGMA^2));

        curves(peakIdx, :) = gMembFnMat * areaOnePeak * peakArea / (sqrt(2 * pi) * psfSigmaWidth_pixels);
    end
    fid = fopen(txtFilepathPeaks, 'w') ;

    fprintf(fid,'%20s\t %12s\t %15s\t %10s\n','PSF sigma width (pixels)', 'Area one peak', 'mean(backgroundNoise)', 'p-value');
    fprintf(fid,'%20.2f\t %12.7f\t %15.9f\t %e\n', psfSigmaWidth_pixels, areaOnePeak, meanBackgroundNoise, probGoodFit);
    fprintf(fid,'%12s\t %15s\n',' ', 'Peak');
    fprintf(fid,['%12s\t', repmat('%15d\t ', 1, numPeaks), '\n'] ,unitStr, (1:numPeaks));
    fprintf(fid, ['%12.1f\t', repmat('%15.6f\t ', 1, numPeaks), '\n'] ,[x*unitsPerPixel; curves]);

    fclose(fid);
end