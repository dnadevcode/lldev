function simplifiedNodeNames = simplify_node_names(nodeNames)
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    srcDirpath = fullfile(appDirpath, 'src');
    matlabSrcDirpath = fullfile(srcDirpath, 'MATLAB');
    if not(strcmp(matlabSrcDirpath, filesep()))
        matlabSrcDirpath = [matlabSrcDirpath, filesep()];
    end
    simplifiedNodeNames = cellfun(@(filepath) get_direct_import_path(filepath, matlabSrcDirpath), nodeNames, 'UniformOutput', false);
    function [directImportPath] = get_direct_import_path(mFilepath, matlabSrcDirpath)
        chopLen = length(matlabSrcDirpath);
        if not(strcmpi(mFilepath(1:(min(end, chopLen))), matlabSrcDirpath))
            directImportPath = mFilepath;
            return;
        end
        tmp_c = strsplit(mFilepath((chopLen + 1):end), filesep());
        [~, filenameSansExt, ~] = fileparts(tmp_c{end});
        packagePath = '';
        dirParts = tmp_c(1:(end - 1));
        isPackagedTF = (length(tmp_c) > 1) && all(cellfun(@(dirname) strcmp(dirname(1), '+'), dirParts));
        if isPackagedTF
            packagePath = strjoin(cellfun(@(dirname) dirname(2:end), tmp_c(1:(end - 1)), 'UniformOutput', false), '.');
        end
        isPackagedTF = not(isempty(packagePath));
        if isPackagedTF
            directImportPath = [packagePath, '.', filenameSansExt];
            wildcardImportPaths = [packagePath, '.*'];
        else
            directImportPath = filenameSansExt;
        end
    end
end