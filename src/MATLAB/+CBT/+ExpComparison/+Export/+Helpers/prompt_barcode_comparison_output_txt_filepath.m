function [aborted, outputFilepath] = prompt_barcode_comparison_output_txt_filepath()
    [outputTxtFilename, outputDirpath] = uiputfile('*.txt', 'Save As');
    aborted = isequal(outputDirpath, 0);
    if aborted
        outputFilepath = '';
        return;
    end
    outputFilepath = fullfile(outputDirpath, outputTxtFilename);
end