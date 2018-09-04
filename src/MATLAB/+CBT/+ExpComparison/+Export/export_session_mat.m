function [matFilepath] = export_session_mat(eteSessionStruct, clusterKey) %#ok<INUSL>
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    defaultMatFilename = sprintf('MMT_%s_%s.mat', strrep(strrep(clusterKey{1}, '[', '('), ']', ')'), timestamp);
  
    defaultETEDirpath = pwd; % todo: change this to default path for session files


    defaultMatFilepath = fullfile(defaultETEDirpath, defaultMatFilename);

    [matFilename, matDirpath] = uiputfile('*.mat', 'Save ETE session as', defaultMatFilepath);
    if isequal(matDirpath, 0)
        return;
    end
    matFilepath = fullfile(matDirpath, matFilename);
    save(matFilepath, 'eteSessionStruct');
    
    fprintf('Saved MMT data ''%s'' to ''%s''\n', clusterKey{1}, matFilepath);
end
