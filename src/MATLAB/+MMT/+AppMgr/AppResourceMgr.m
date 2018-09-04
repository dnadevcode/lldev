classdef (Sealed) AppResourceMgr < handle
    % APPRESOURCEMGR - Application resource management class helps manage
    %   functionality related to resources available to the app
    %
    % Note: An instance of APPRESOURCEMGR should be retrieved
    %   using get_instance since it will be defined as a persistent
    %   variable using the singleton design pattern.
    %
    % http://mathworks.com/help/matlab/ref/persistent.html
    % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
    %
    % Authors:
    %   Saair Quaderi
    
    properties (Constant)
        Version = [0, 0, 1];
        
        AppResourceMgrsDataPoolID = sprintf('%sAppResourceMgrs', AppMgr.AppDataPoolViewScreen.HideDataPoolPrefix);
    end
    properties (Constant, Access = private)
        RequiredRootPkgParentDirname = 'Packages'
    end
    properties
        AppSession
        Dirpaths = containers.Map('KeyType', 'char', 'ValueType', 'char');
    end
    
    methods (Access = private)
        function [appRsrcMgr] = AppResourceMgr(appSess)
            % APPRESOURCEMGR - Constructor for instances of APPRESOURCEMGR
            %
            %  Inputs:
            %    appSess (optional; defaults to instance of AppSession
            %     returned by AppSession.get_instance)
            %
            %  Outputs:
            %    appRsrcMgr
            %      AppResourceMgr object
            % 
            %  Authors:
            %    Saair Quaderi
            
            if nargin < 1
                appSess = [];
            end
            
            if isempty(appSess)
                import AppMgr.AppSession;
                appSess = AppSession.get_instance();
            end
            appRsrcMgr.AppSession = appSess;
            
            
            import AppMgr.AppResourceMgr;
            
            packagesDirpath = AppResourceMgr.find_root_package_parent_dirpath();
            [appDirpath, packagesDirname] = fileparts(packagesDirpath);
            if not(strcmp(packagesDirname,  AppResourceMgr.RequiredRootPkgParentDirname))
                error('Expected matlab package directory roots to have a parent directory named ''%s''', ...
                    AppResourceMgr.RequiredRootPkgParentDirname);
            end
            
            % Have to call the non-static private p_* versions because
            % calling the static versions could retrigger AppResourceMgr
            % constructor through get_app_instance which might result in an
            % infinite loop
            appRsrcMgr.p_init_dirpath('App', appDirpath);
            appRsrcMgr.p_init_dirpath('Packages', packagesDirpath);
            appRsrcMgr.p_init_dirpath('Assets', fullfile(appDirpath, 'Assets'));
            appRsrcMgr.p_init_dirpath('DataCache', fullfile(appDirpath, 'DataCache'));
            appRsrcMgr.p_init_dirpath('SettingFiles', fullfile(appDirpath, 'SettingFiles'));
            
            appRsrcMgr.p_add_all_packages();
        end
        
        function [] = p_add_all_packages(appRsrcMgr)
            % P_ADD_ALL_PACKAGES - Private function to add the package
            %   directory path and all descendant subdirectory paths to the
            %   Matlab path
            %
            % Inputs:
            %   appRsrcMgr
            %     the Application Resource Manager object which contains
            %     the information about where the packages directory is
            %     located
            %
            % Side effects:
            %    the Matlab path has the package directory path and all
            %    descendant subdirectory paths added to it
            %
            % Authors:
            %   Saair Quaderi
            
            addpath(genpath(appRsrcMgr.p_get_packages_dirpath()));
        end
        
        function [] = p_init_dirpath(appRsrcMgr, dirpathKey, dirpath)
            % P_INIT_DIRPATH - Private function to  making the directory 
            %   if it does not already exist avd add/set the directory
            %   path specified in the Application Resource Manager with the
            %   specified path key
            %
            % Inputs:
            %   appRsrcMgr
            %     the Application Resource Manager object which contains
            %     the information about where the packages directory is
            %     located
            %   dirpathKey
            %     the key to associate with the directory path
            %   dirpath
            %     the directory path
            %
            % Authors:
            %   Saair Quaderi
            
            import FancyIO.mkdirp;
            mkdirp(dirpath);
            if not(isKey(appRsrcMgr.Dirpaths, dirpathKey))
                appRsrcMgr.p_set_dirpath(dirpathKey, dirpath);
            else
                error('Path already exists');
            end
        end
        
        function [] = p_set_dirpath(appRsrcMgr, dirpathKey, dirpath)
            % P_SET_DIRPATH - Private function to set the directory
            %   path specified in the Application Resource Manager with the
            %   specified path key
            %
            % Inputs:
            %   appRsrcMgr
            %     the Application Resource Manager object which contains
            %     the information about where the packages directory is
            %     located
            %   dirpathKey
            %     the key to associate with the directory path
            %   dirpath
            %     the directory path
            %
            % Authors:
            %   Saair Quaderi
            
            appRsrcMgr.Dirpaths(dirpathKey) = dirpath;
        end
        
        function [appDirpath] = p_get_app_dirpath(appRsrcMgr)
            % P_GET_APP_DIRPATH - Private function to get the directory
            %   path for the application
            %
            % Inputs:
            %   appRsrcMgr
            %     the Application Resource Manager object which contains
            %     the information about where the application directory is
            %     located
            %
            % Outputs:
            %   appDirpath
            %      the directory path for the application
            %
            % Authors:
            %   Saair Quaderi
            
            appDirpath = appRsrcMgr.Dirpaths('App');
        end
        
        function [packagesDirpath] = p_get_packages_dirpath(appRsrcMgr)
            % P_GET_PACKAGES_DIRPATH - Private function to get the
            %   directory path for packages
            %
            % Inputs:
            %   appRsrcMgr
            %     the Application Resource Manager object which contains
            %     the information about where the packages directory is
            %     located
            %
            % Outputs:
            %   packagesDirpath
            %      the directory path for the packages
            %
            % Authors:
            %   Saair Quaderi
            
            packagesDirpath = appRsrcMgr.Dirpaths('Packages');
        end
        
        function [dirpath] = p_get_dirpath(appRsrcMgr, dirpathKey)
            % P_GET_DIRPATH - Private function to get the
            %   path associated with the key specified
            %
            % Inputs:
            %   appRsrcMgr
            %     the Application Resource Manager object which contains
            %     the information about where the packages directory is
            %     located
            %   dirpathKey
            %     the key for the directory path of interest
            %
            % Outputs:
            %   dirpath
            %      the directory path for the key of interest
            %
            % Authors:
            %   Saair Quaderi
            
            appDirpath = appRsrcMgr.p_get_app_dirpath();
            if appRsrcMgr.Dirpaths.isKey(dirpathKey)
                dirpath = appRsrcMgr.Dirpaths(dirpathKey);
            else
                defaultDirpath = fullfile(appDirpath, dirpathKey);
                if not(exist(defaultDirpath, 'dir'))
                    defaultDirpath = appDirpath;
                end
                dirpath = uigetdir(defaultDirpath, sprintf('Select ''%s'' directory', dirpathKey));
                if not(isequal(dirpath, 0))    
                    appRsrcMgr.Dirpaths(dirpathKey) = dirpath;
                end
            end
        end
    end
    methods (Static)
        function [] = init_dirpath(dirpathKey, dirpath)
            % INIT_DIRPATH - Public static function to  making the
            %   directory if it does not already exist avd add/set the
            %   directory path specified in the instance of AppResourceMgr
            %   returned by AppResourceMgr.get_instance
            %
            % Inputs:
            %   dirpathKey
            %     the key to associate with the directory path
            %   dirpath
            %     the directory path
            %
            % Authors:
            %   Saair Quaderi
            
            import AppMgr.AppResourceMgr;
            appRsrcMgr = AppResourceMgr.get_instance();
            appRsrcMgr.p_init_dirpath(dirpathKey, dirpath);
        end
        
        function [] = set_dirpath(dirpathKey, dirpath)
            % SET_DIRPATH - Public static function to set the directory
            %   path specified in the instance of AppResourceMgr returned
            %   by AppResourceMgr.get_instance
            %
            % Inputs:
            %   dirpathKey
            %     the key to associate with the directory path
            %   dirpath
            %     the directory path
            %
            % Authors:
            %   Saair Quaderi
            
            import AppMgr.AppResourceMgr;
            appRsrcMgr = AppResourceMgr.get_instance();
            appRsrcMgr.p_set_dirpath(dirpathKey, dirpath);
        end
        
        function [dirpath] = get_dirpath(dirpathKey)
            % GET_DIRPATH - Public static function to get the
            %   path associated with the key specified from the instance of
            %   AppResourceMgr returned by AppResourceMgr.get_instance
            %
            % Inputs:
            %   dirpathKey
            %     the key for the directory path of interest
            %
            % Outputs:
            %   dirpath
            %      the directory path for the key of interest
            %
            % Authors:
            %   Saair Quaderi
            import AppMgr.AppResourceMgr;
            appRsrcMgr = AppResourceMgr.get_instance();
            dirpath = appRsrcMgr.p_get_dirpath(dirpathKey);
        end

        function [packagesDirpath] = get_packages_dirpath()
            % GET_PACKAGES_DIRPATH - Public static function to get the
            %   directory path for packages from the instance of
            %   AppResourceMgr returned by AppResourceMgr.get_instance
            %
            % Outputs:
            %   packagesDirpath
            %      the directory path for the packages
            %
            % Authors:
            %   Saair Quaderi
            
            import AppMgr.AppResourceMgr;
            appRsrcMgr = AppResourceMgr.get_instance();
            packagesDirpath = appRsrcMgr.p_get_packages_dirpath();
        end
        
        function [appDirpath] = get_app_dirpath()
            % GET_APP_DIRPATH - Public static function to get the
            %   directory path for the application from the instance of
            %   AppResourceMgr returned by AppResourceMgr.get_instance
            %
            % Outputs:
            %   appDirpath
            %      the directory path for the application
            %
            % Authors:
            %   Saair Quaderi
            
            import AppMgr.AppResourceMgr;
            appRsrcMgr = AppResourceMgr.get_instance();
            appDirpath = appRsrcMgr.p_get_app_dirpath();
        end
        
        function [] = add_all_packages()
            % ADD_ALL_PACKAGES - Public static function to add the package
            %   directory path and all descendant subdirectory paths to the
            %   Matlab path from the instance of AppResourceMgr returned by
            %   AppResourceMgr.get_instance
            %
            % Side effects:
            %    the Matlab path has the package directory path and all
            %    descendant subdirectory paths added to it
            %
            % Authors:
            %   Saair Quaderi
            
            import AppMgr.AppResourceMgr;
            appRsrcMgr = AppResourceMgr.get_instance();
            appRsrcMgr.p_add_all_packages();
        end
        
        function appRsrcMgr = get_instance(varargin)
            % GET_INSTANCE - returns an instance of AppResourceMgr,
            %   generating it if a valid one doesn't already exist and
            %   returning the valid existing one otherwise
            %
            % Inputs:
            %  varargin (any number of arguments)
            %   If one of arguments is 'verbose' (case insensitive), the
            %    function prints vebose console text about what occurs
            %    (e.g. specifying whether the app resource manager was
            %      retrieved or newly generated)
            %
            % Outputs:
            %  appRsrcMgr
            %    the instance of AppResourceMgr
            %
            % Authors:
            %   Saair Quaderi
            
            import AppMgr.AppSession;
            appSess = AppSession.get_instance();
            
            
            strArgMask = cellfun(@(arg) (ischar(arg) && isrow(arg)), varargin);
            strArgs = cellfun(@lower, varargin(strArgMask), 'UniformOutput', false);
            verbose = not(isempty(intersect(strArgs, {'verbose'})));
            persistent persistentLocalAppRsrcMgr
            import AppMgr.AppResourceMgr;
            if isempty(persistentLocalAppRsrcMgr) || not(isvalid(persistentLocalAppRsrcMgr))
                if verbose
                    fprintf('Generating New App Resource Manager...\n');
                end
                persistentLocalAppRsrcMgr = AppResourceMgr(appSess);
            else
                if verbose
                    fprintf('Retrieving App Resource Manager from Memory...\n');
                end
            end
            appRsrcMgr = persistentLocalAppRsrcMgr;
        end
    end
    
    methods (Static, Access = private)
        function rootPkgParentDirpath = find_root_package_parent_dirpath()
            % FIND_ROOT_PACKAGE_PARENT_DIRPATH - Private static function
            %  that returns the path of the parent directory of the
            %  root package directory containing this file
            %
            % Outputs:
            %   rootPkgParentDirpath
            %     the path of the parent directory of the root package
            %     directory containing this file
            %
            % Authors:
            %   Saair Quaderi
            
            currFilepath = mfilename('fullpath');
            [currDirpath, ~, ~] = fileparts(currFilepath);
            splitPathStrs = strsplit(fileparts(currDirpath), filesep);
            packageDirStrIdx = length(splitPathStrs);
            while ((packageDirStrIdx > 1) && ...
                    not(isempty(splitPathStrs{packageDirStrIdx})) && ...
                    (strcmp(splitPathStrs{packageDirStrIdx}(1), '+')))
                packageDirStrIdx = packageDirStrIdx - 1;
            end
            rootPkgParentDirpath = fullfile(splitPathStrs{1:packageDirStrIdx});
            if (isunix() && not(isempty(rootPkgParentDirpath)))
                rootPkgParentDirpath = [filesep(), rootPkgParentDirpath];
            end
        end
    end
end
