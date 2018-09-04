function [outputFilepath] = export_results_txt(predictedCurveAfterPsf, bindingNtSequence, filename, outputFilepath)
    fileID = fopen(outputFilepath, 'w');
    fprintf(fileID, 'binding sequence\tDNA sequence\n');
    fprintf(fileID, '%s\t%s\t', bindingNtSequence, filename);
    fprintf(fileID, '%f\n', predictedCurveAfterPsf');
    fclose(fileID);
end