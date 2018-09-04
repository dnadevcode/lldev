function [] = export_ppa_txt(txtFilepathPPA, probGoodFit, peakPositionsVect, peakAreasVect, psfSigmaWidth_pixels, areaOnePeak, meanBackgroundNoise, unitsPerPixel, unitStr, deltPos_all, deltAre_all)
    fid = fopen(txtFilepathPPA, 'w') ;
    fprintf(fid,'%20s\t %12s\t %15s\t %10s\n','PSF sigma width (pixels)', 'Area one peak', 'mean(Noise)', 'p-value');
    fprintf(fid,'%20.2f\t %12.7f\t %15.9f\t %e\n', psfSigmaWidth_pixels, areaOnePeak, meanBackgroundNoise, probGoodFit);
    if strcmp(selected.Tag, 'lsq')
        fprintf(fid,'%4s\t %12s\t %15s\t %10s\t %10s\n','Peak', unitStr, 'std(position)', 'Area one peak', 'std(Area)');
        fprintf(fid,'%2d\t %12.1f\t %15.3f\t %10.2f\t %10.3f\n', [(1:length(peakAreasVect)); unitsPerPixel*peakPositionsVect; deltPos_all*unitsPerPixel; peakAreasVect; deltAre_all]);
    else
        fprintf(fid,'%4s\t %12s\t %10s\n','Peak', unitStr, 'Area one peak');
        fprintf(fid,'%2d\t %12.1f\t %10.2f\n', [(1:length(peakAreasVect)); unitsPerPixel*peakPositionsVect; peakAreasVect]);
    end
    fclose(fid);
end