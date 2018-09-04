function [aborted, tableKymoMolLenStats, summaryOutputFilepath] = export_kymos_mol_len_stats_summary(timeframeKymoMolLenMat, summaryOutputFilepath)
    import OldDBM.General.Import.try_prompt_timeframe_kymo_mol_len_mat;
    aborted = false;
    tableKymoMolLenStats = [];
    defaultSummaryOutputFilepath = '';
    if nargin < 1
        % TODO: consider depricating this functionality and getting data
        %  from dbmODW
    
        summaryOutputFilepath = '';
        [aborted, timeframeKymoMolLenMat, inputFilepath] = try_prompt_timeframe_kymo_mol_len_mat();
        if aborted
            return;
        end
        [defaultSummaryOutputDirpath, inputFilenameSansExt] = fileparts(inputFilepath);
        defaultSummaryOutputFilename = sprintf('%s_stats_summary.tsv', inputFilenameSansExt);
        defaultSummaryOutputFilepath = fullfile(defaultSummaryOutputDirpath, defaultSummaryOutputFilename);
    end
    if nargin < 2
        [summaryOutputFilename, summaryOutputDirpath] = uiputfile('*.tsv', 'Save mol len stats summary as', defaultSummaryOutputFilepath);
        aborted = isequal(summaryOutputDirpath, 0);
        if aborted
            return;
        end
        summaryOutputFilepath = fullfile(summaryOutputDirpath, summaryOutputFilename);
    end

    % -- Calculate mean, std and skewness --
    % -- and print to screen --
    kymosMolLenMean = nanmean(timeframeKymoMolLenMat)';
    kymosMolLenStd = nanstd(timeframeKymoMolLenMat)';
    kymosMolLenSkewness = skewness(timeframeKymoMolLenMat)';

    tableColNames = {'Mol Len Mean', 'Mol Len Std', 'Mol Len Skewness'};
    tableColNamesValid = matlab.lang.makeValidName(tableColNames);
    tableRowNames = arrayfun(@(x) sprintf('Kymo %d', x), (1:size(timeframeKymoMolLenMat, 2))', 'UniformOutput', false);
    tableRowNamesValid = matlab.lang.makeValidName(tableRowNames);
    tableKymoMolLenStats = table(...
        kymosMolLenMean, kymosMolLenStd, kymosMolLenSkewness, ...
        'VariableNames', tableColNamesValid, ...
        'RowNames', tableRowNamesValid);
    tableKymoMolLenStats.Properties.Description = 'Kymo Timeframe Mol Len Stats';

    % -- Save data to files --

    writetable(tableKymoMolLenStats, summaryOutputFilepath, ...
        'Delimiter', '\t', ...
        'WriteVariableNames', true, ...
        'WriteRowNames', true, ...
        'FileType', 'text');
    
    fprintf('%s: ', tableKymoMolLenStats.Properties.Description);
    disp(tableKymoMolLenStats);
end