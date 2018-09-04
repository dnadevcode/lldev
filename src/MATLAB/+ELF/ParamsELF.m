classdef ParamsELF < handle
    % PARAMSELF 
    
    properties (Constant, Hidden = true)
        default_psfSigmaWidth_nm = 450; % Point Spread Function sigma width (nm)
        default_pixelWidth_nm = 159;  % Pixel width (nm)
        default_areaOnePeak = 0.012; % Total intensity of a single fluorophore (mean value)
        default_areaOnePeakStd = 0.0005;  % Standard deviation of area one peak
        default_confidenceInterval = 2; % Number of standard deviation used for the intervals of confidence
        default_meanBackgroundNoise = 0.0431*0.0056; % Noise (mean value) when the minimum intensity of the barcode is set to 0
        default_stdBackgroundNoise = 0.0000958; % Standard deviation of the noise
        default_barcodeLineColor = [0.274, 0.266, 0.454];
        default_fitLineColor = [0.721, 0.125, 0.078];
        default_peaksPositionRectColor = [0, 0.7, 0.5];
    end
    
    properties (SetAccess = private)
        psfSigmaWidth_nm = ELF.ParamsELF.default_psfSigmaWidth_nm;
        pixelWidth_nm = ELF.ParamsELF.default_pixelWidth_nm;
        areaOnePeak = ELF.ParamsELF.default_areaOnePeak;
        areaOnePeakStd = ELF.ParamsELF.default_areaOnePeakStd;
        confidenceInterval = ELF.ParamsELF.default_confidenceInterval;
        meanBackgroundNoise = ELF.ParamsELF.default_meanBackgroundNoise;
        stdBackgroundNoise = ELF.ParamsELF.default_stdBackgroundNoise
        barcodeLineColor = ELF.ParamsELF.default_barcodeLineColor;
        fitLineColor = ELF.ParamsELF.default_fitLineColor;
        peaksPositionRectColor = ELF.ParamsELF.default_peaksPositionRectColor;
    end
    
    methods
        function [paramsELF] = ParamsELF()
            paramsELF.load_file_params_struct();
        end
        
        function [fileParamsELF] = load_file_params_struct(paramsELF)
            import Fancy.IO.ini2struct;
            defaultSettingsFilename = 'ELF.ini';
            elfParamSectionName = 'elfParams';
            
            import Fancy.AppMgr.AppResourceMgr;
            defaultSettingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
            defaultSettingsFilepath = fullfile(defaultSettingsDirpath, defaultSettingsFilename);
            
            [settingsFilename, settingsDirpath] = uigetfile('*.ini','Select ELF Settings Ini File', defaultSettingsFilepath);
            if isequal(settingsDirpath, 0)
                fileParamsELF = [];
                return;
            end
            settingsIniFilepath = fullfile(settingsDirpath, settingsFilename);
            
            fileParamsELF = ini2struct(settingsIniFilepath);
            
            if not(isfield(fileParamsELF, elfParamSectionName))
                warning('Could not find ELF param secion name (''%s'') in ini file\n', elfParamSectionName);
                return;
            end
            
            fileParamsELF = fileParamsELF.(elfParamSectionName);
            fileParamFieldNames = fieldnames(fileParamsELF);
            
            numParamNames = length(fileParamFieldNames);
            for paramNameNum = 1:numParamNames
                fileParamFieldName = fileParamFieldNames{paramNameNum};
                if isprop(paramsELF, fileParamFieldName)
                    paramsELF.(fileParamFieldName) = fileParamsELF.(fileParamFieldName);
                else
                    warning('Unrecognized field in ELF settings, ''elfParams'': ''%s''\n', fileParamFieldName);
                end
            end
        end
    end
end