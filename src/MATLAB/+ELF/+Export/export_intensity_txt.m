function [] = export_intensity_txt(txtFilepathIntensity, probGoodFit, psfSigmaWidth_pixels, areaOnePeak, meanBackgroundNoise, xIdxs, unitsPerPixel, unitStr, totalFit)
    fid = fopen(txtFilepathIntensity, 'w') ;
    fprintf(fid,'%20s\t %12s\t %15s\t %10s\n','PSF sigma width (pixels)', 'Area one peak', 'mean(Noise)','p-value');
    fprintf(fid,'%20.2f\t %12.7f\t %15.9f\t %e\n', psfSigmaWidth_pixels, areaOnePeak, meanBackgroundNoise, probGoodFit);
    fprintf(fid,'%12s\t %15s\n',unitStr, 'Intensity');
    fprintf(fid,'%12.1f %15.6f\n', [xIdxs*unitsPerPixel; totalFit']);
    fclose(fid);
end