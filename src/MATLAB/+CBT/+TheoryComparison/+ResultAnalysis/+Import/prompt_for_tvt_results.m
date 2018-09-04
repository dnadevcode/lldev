function [aborted, tvtResultNames, tvtResultStructs] = prompt_for_tvt_results()
    % get_tvt_results - get TvT results structs
    import CBT.TheoryComparison.ResultAnalysis.Import.prompt_filepaths_for_tvt_results;

    [aborted, filepaths] = prompt_filepaths_for_tvt_results();

    if aborted
        tvtResultStructs = cell(0, 1);
        tvtResultNames = cell(0, 1);
        return;
    end

    function filename = get_filename(filepath)
        [~, filename, ~] = fileparts(filepath);
    end

    tvtResultNames = cellfun(@get_filename, filepaths, 'UniformOutput', false);
    tvtResultStructs = cellfun(@load, filepaths, 'UniformOutput', false);
end