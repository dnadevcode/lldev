function [settingsStructCA] = get_contig_assembly_settings_struct()

    settingsStructCA.minValidShortestSeq = 4 * barcodeGenSettings.psfSigmaWidth_nm / barcodeGenSettings.meanBpExt_nm;

    settingsStructCA.qMax = round(5*10^5);
    settingsStructCA.overlapLim = 2;
    settingsStructCA.allowOverlap = (settingsStructCA.overlapLim > 0);
    settingsStructCA.forcePlace = false;
    settingsStructCA.pThreshold = 0.501;
    settingsStructCA.data = 'Unknown';
    settingsStructCA.numRandBarcodes = 1000; %number of PR barcodes
    settingsStructCA.flipAllowed = true;
    settingsStructCA.shouldFormatNamesTF = true;


    % isDefault = true;
    % if not(isDefault)
    %     prompts = {...
    %         'Name of sample:', ...
    %         'Allowed overlap (px):', ...
    %         'Force place contigs:', ...
    %         'Shortest seq (bp):', ...
    %         'Format names:' ...
    %         };
    %     defaultVals = { ...
    %         'Unknown', ...
    %         num2str(2), ...
    %         'No', ...
    %         num2str(7000), ...
    %         'Yes' ...
    %         };
    %     dlg_title = 'Input settings';
    %     num_lines = 1;
    %     answer = inputdlg(prompts, dlg_title, num_lines, defaultVals);
    % 
    %     %---Input settings dialog---
    %     settingsStructCA.data = answer{1};
    %     settingsStructCA.overlapLim = str2double(answer{2});
    %     settingsStructCA.forcePlace = not(strcmpi(answer{3}(1), 'N'));
    %     settingsStructCA.minValidShortestSeq = round(max(minValidShortestSeq, str2double(answer{4})));
    %     settingsStructCA.shouldFormatNamesTF = strcmpi(answer{5}(1),'Y');
    % end

end
