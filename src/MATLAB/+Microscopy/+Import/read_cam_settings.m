function [fileParamsCam, camParamsIniFilepath] = read_cam_settings(camParamsIniFilepath, appDirpath)
    if (nargin < 1) || isempty(camParamsIniFilepath)
        import Microscopy.Import.prompt_cam_ini_filepath;
        camParamsIniFilepath = prompt_cam_ini_filepath();
    end
    if (nargin < 2) || isempty(appDirpath)
        import Fancy.AppMgr.AppResourceMgr;
        appDirpath = AppResourceMgr.get_app_dirpath();
    end
    import Fancy.IO.ini2struct;
    import Microscopy.Import.process_cam_settings;
    fileParamsCam = process_cam_settings(ini2struct(camParamsIniFilepath), appDirpath);
end