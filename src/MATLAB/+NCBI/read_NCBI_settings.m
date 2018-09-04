function [fileParamsNCBI, ncbiParamsIniFilepath] = read_NCBI_settings(ncbiParamsIniFilepath, appDirpath)
    if (nargin < 1) || isempty(ncbiParamsIniFilepath)
        import NCBI.prompt_NCBI_ini_filepath;
        ncbiParamsIniFilepath = prompt_NCBI_ini_filepath();
    end
    if (nargin < 2) || isempty(appDirpath)
        import Fancy.AppMgr.AppResourceMgr;
        appDirpath = AppResourceMgr.get_app_dirpath();
    end
    import Fancy.IO.ini2struct;
    import NCBI.process_NCBI_settings;
    fileParamsNCBI = process_NCBI_settings(ini2struct(ncbiParamsIniFilepath), appDirpath);
end