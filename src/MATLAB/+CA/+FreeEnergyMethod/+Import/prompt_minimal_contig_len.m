function [lowLim_pixels] = prompt_minimal_contig_len(meanBpExt_pixels, defaultMinContigLen_kbps)
    if nargin < 2
        defaultMinContigLen_kbps = 12;
    end
    dlg_titleLim = 'Minimal permissible contig limit';
    lowLimPrompt = {'Minimal permissible contig length (kbps):'};
    defaultValsLim = {num2str(defaultMinContigLen_kbps)};
    num_lines = 1;
    lowLim_pixels = round(str2double(inputdlg(lowLimPrompt,dlg_titleLim,num_lines,defaultValsLim))* meanBpExt_pixels * 1000);
end