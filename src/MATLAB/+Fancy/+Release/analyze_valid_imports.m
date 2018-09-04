function [allValidImportPaths] = analyze_valid_imports()

    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    srcDirpath = fullfile(appDirpath, 'src');
    matlabSrcDirpath = fullfile(srcDirpath, 'MATLAB');
    
    filepaths = {};
    dirpathsToExplore = {matlabSrcDirpath};
    
    while not(isempty(dirpathsToExplore))
        currDirpath = dirpathsToExplore{1};
        d = dir(currDirpath);
        isDirMask = [d.isdir];
        names = {d.name};
        names = names(:);
        filepaths = [filepaths; fullfile(currDirpath, names(~isDirMask))];
        dirpathsToExplore = [dirpathsToExplore(2:end); fullfile(currDirpath, setdiff(names(isDirMask), {'.'; '..'}))];
    end
    if not(strcmp(matlabSrcDirpath, filesep()))
        matlabSrcDirpath = [matlabSrcDirpath, filesep()];
    end
    [~, ~, fileExts] = cellfun(@fileparts, filepaths, 'UniformOutput', false);
    isMMask = cellfun(@(fileExt) strcmpi('.m', fileExt), fileExts);
    mFilepaths = filepaths(isMMask);
    [directImportPaths, wildcardImportPaths, directSubMethodImportPaths, wildcardSubMethodImportPaths] = cellfun(@(mFilepath) process_tmp(mFilepath, matlabSrcDirpath), mFilepaths, 'UniformOutput', false);
    
    directImportPaths = vertcat(directImportPaths{:});
    wildcardImportPaths = vertcat(wildcardImportPaths{:});
    directSubMethodImportPaths = vertcat(directSubMethodImportPaths{:});
    wildcardSubMethodImportPaths = vertcat(wildcardSubMethodImportPaths{:});
    
    allValidImportPaths = [unique([directImportPaths; directSubMethodImportPaths;]); unique([wildcardImportPaths; wildcardSubMethodImportPaths])];
    
    
    function [directImportPaths, wildcardImportPaths, directSubMethodImportPaths, wildcardSubMethodImportPaths] = process_tmp(mFilepath, matlabSrcDirpath)
        chopLen = length(matlabSrcDirpath);
        wildcardImportPaths = cell(0, 1);
        tmp_c = strsplit(mFilepath((chopLen + 1):end), filesep());
        [~, filenameSansExt, ~] = fileparts(tmp_c{end});
        packagePath = '';
        isPackagedTF = (length(tmp_c) > 1) && all(cellfun(@(dirname) strcmp(dirname(1), '+'), tmp_c(1:(end - 1))));
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
        directSubMethodImportPaths = get_static_methods_names(directImportPath);
        wildcardSubMethodImportPaths = cell(0, 1);
        if not(isempty(directSubMethodImportPaths))
            wildcardSubMethodImportPaths = {[directImportPath, '.*']};
        end
        directImportPaths = {directImportPath};
    end

    function [methodImportPaths] = get_static_methods_names(classname)
        methodImportPaths = cell(0, 1);
        fn_starts_with = @(str1, str2) strcmp(str1(1:min(end,length(str2))), str2);
        try
            [~, A] = methods(classname, '-full');
        catch e
            warning('Syntax error in ''%s'' was detected', classname);
        end
        if isempty(A)
            return;
        end
        isStaticMask = cellfun(@(str) strcmpi(str, 'Static'), A(:, 1));
        uninheritedMask = cellfun(@(str) fn_starts_with(str, [classname, '.']), A(:, 4));
        importableMask = isStaticMask & uninheritedMask;
        methodImportPaths = A(importableMask, 4);
    end
end