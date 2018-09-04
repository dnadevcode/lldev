classdef (Sealed) KymoFactory < handle
    % KYMOFACTORY - Makes Kymo objects
    %
    % Note: An instance of KYMOFACTORY should be retrieved
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
        
%         DefaultFitRangeToCleanedDataMode = true;
%         DefaultKeepMovieObjsSlim = true;
%         DefaultStorageMode = Microscopy.KymoStorageMode.get_default_storage_mode();
        DefaultDefaultMatDirpath = Fancy.AppMgr.AppResourceMgr.get_app_dirpath();
        DefaultAutoUpdateDefaultMatDirpath = true;
    end
    properties (SetAccess = private)
%         FitRangeToCleanedDataMode = Microscopy.KymoFactory.DefaultFitRangeToCleanedDataMode;
%         KeepMovieObjsSlim = Microscopy.KymoFactory.DefaultKeepMovieObjsSlim;
%         StorageMode = Microscopy.KymoFactory.DefaultStorageMode;
        DefaultMatDirpath = Microscopy.KymoFactory.DefaultDefaultMatDirpath;
        AutoUpdateDefaultMatDirpath = Microscopy.KymoFactory.DefaultAutoUpdateDefaultMatDirpath;
    end
    
    methods (Access = private)
        function [kymoF] = KymoFactory()
            % KYMOFACTORY - Constructor, purposefully made
            % private to follow Singleton design pattern:
            %
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            %
            % Use get_instance publicly
        end
    end
    
    methods (Static)
        function [singletonKymoF] = get_instance()
            % GET_INSTANCE - retrieves the single instance of this data
            %   manager
            %
            % Outputs:
            %   singletonKymoF
            %     the instance of the kymograph factory
            %
            % Side-effects:
            %   Creates the local grayscale movie factory if it does not
            %   already exist
            %
            % Authors:
            %   Saair Quaderi
         
            % Part of the Singleton design pattern:
            % http://mathworks.com/help/matlab/matlab_oop/controlling-the-number-of-instances.html
            persistent localPersisentKymoF;
            if isempty(localPersisentKymoF) || not(isvalid(localPersisentKymoF))
                localPersisentKymoF = Microscopy.KymoFactory();
            end
            singletonKymoF = localPersisentKymoF;
        end
    end
    
    methods
        
        function [failMsg, kymoObj] = load_kymo_from_mat(kymoF, srcKymoFilepath)
            if nargin < 2
                srcKymoFilepath = [];
            end
            if isempty(srcKymoFilepath)
                [aborted, srcKymoFilepath] = kymoF.prompt_single_kymo_mat();
            else
                aborted = false;
            end
            failMsg = false;
            if aborted || isempty(srcKymoFilepath)
                kymoObj = [];
                failMsg = 'No mat file was specified to make the kymo object from';
                return;
            end
            
            import Microscopy.Import.import_kymo_obj;
            kymoObj = import_kymo_obj(srcKymoFilepath);
        end
    end
    methods (Access = private)

        function [aborted, srcMatFilepath] = prompt_single_kymo_mat(kymoF)
            defaultMatDirpath = kymoF.DefaultMatDirpath;
            autoUpdateDefaultMatDirpath = kymoF.AutoUpdateDefaultMatDirpath;
            import Microscopy.Import.try_prompt_kymo_filepaths;
            [aborted, srcMatFilepaths] = try_prompt_kymo_filepaths([], false, defaultMatDirpath);
            if aborted
                srcMatFilepath = '';
            else
                srcMatFilepath = srcMatFilepaths{1};
                if autoUpdateDefaultMatDirpath
                    [defaultMatDirpath, ~, ~] = fileparts(srcMatFilepath);
                    kymoF.DefaultMatDirpath = defaultMatDirpath;
                end
            end
        end
    end
    
end

