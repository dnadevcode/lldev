function [matFilepath] = export_cluster_mat(mmtResultsData, clusterKey) %#ok<INUSL>
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    defaultMatFilename = sprintf('MMT_%s_%s.mat', strrep(strrep(clusterKey, '[', '('), ']', ')'), timestamp);
    [matFilename, matDirpath] = uiputfile('*.mat', 'Save MMT comparison data as', pwd);
    if isequal(matDirpath, 0)
        return;
    end
    matFilepath = fullfile(matDirpath, matFilename);
    save(matFilepath, 'mmtResultsData');
    
    fprintf('Saved MMT data ''%s'' to ''%s''\n', clusterKey, matFilepath);
end
