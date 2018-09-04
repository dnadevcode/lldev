classdef ParamsELT < handle
    % PARAMSELT
    
    properties (Constant, Hidden = true)
        default_bindingSequence = 'CCTCAGC';
        default_psfSigmaWidth_nm = 450; % Point Spread Function sigma width (nm)
        default_meanBpExt_nm = 0.332; % Mean basepair extension (nm)
        default_pixelWidth_nm = 159;  % Pixel width (nm)
        default_shouldPlotExpectedBindingLocs = true;
        default_shouldPlotExpectedBarcodePlot = true;
        default_shouldDispExpectedBarcode = true;
        default_shouldSaveTxtResults = true;
    end
    
    properties (SetAccess = private)
        bindingSequence = ELT.ParamsELT.default_bindingSequence;
        psfSigmaWidth_nm = ELT.ParamsELT.default_psfSigmaWidth_nm;
        meanBpExt_nm = ELT.ParamsELT.default_meanBpExt_nm;
        pixelWidth_nm = ELT.ParamsELT.default_pixelWidth_nm;
        shouldPlotExpectedBindingLocs = ELT.ParamsELT.default_shouldPlotExpectedBindingLocs;
        shouldPlotExpectedBarcodePlot = ELT.ParamsELT.default_shouldPlotExpectedBarcodePlot;
        shouldDispExpectedBarcode = ELT.ParamsELT.default_shouldDispExpectedBarcode;
        shouldSaveTxtResults = ELT.ParamsELT.default_shouldSaveTxtResults;
    end
    
    methods
        function [paramsELT] = ParamsELT()
            paramsELT.load_file_params_struct();
        end
        
        function [fileParamsELT] = load_file_params_struct(paramsELT)
            import Fancy.IO.ini2struct;
            defaultSettingsFilename = 'ELT.ini';
            elfParamSectionName = 'eltParams';
            
            import Fancy.AppMgr.AppResourceMgr;
            defaultSettingsDirpath = AppResourceMgr.get_dirpath('SettingFiles');
            defaultSettingsFilepath = fullfile(defaultSettingsDirpath, defaultSettingsFilename);
            
            [settingsFilename, settingsDirpath] = uigetfile('*.ini','Select ELF Settings Ini File', defaultSettingsFilepath);
            if isequal(settingsDirpath, 0)
                fileParamsELT = [];
                return;
            end
            settingsIniFilepath = fullfile(settingsDirpath, settingsFilename);
            
            fileParamsELT = ini2struct(settingsIniFilepath);
            
            if not(isfield(fileParamsELT, elfParamSectionName))
                warning('Could not find ELT param secion name (''%s'') in ini file\n', elfParamSectionName);
                return;
            end
            
            fileParamsELT = fileParamsELT.(elfParamSectionName);
            fileParamFieldNames = fieldnames(fileParamsELT);
            
            numParamNames = length(fileParamFieldNames);
            for paramNameNum = 1:numParamNames
                fileParamFieldName = fileParamFieldNames{paramNameNum};
                if isprop(paramsELT, fileParamFieldName)
                    paramsELT.(fileParamFieldName) = fileParamsELT.(fileParamFieldName);
                else
                    warning('Unrecognized field in ELT settings, ''elfParams'': ''%s''\n', fileParamFieldName);
                end
            end
        end
        
        function [pELT] = prompt_settings_verification(pELT)
            import Fancy.Utils.extract_fields;
            
            curr_default_bindingSequence = pELT.bindingSequence;
            curr_default_psfSigmaWidth_nm = pELT.psfSigmaWidth_nm;
            curr_default_meanBpExt_nm = pELT.meanBpExt_nm;
            
            curr_default_shouldPlotExpectedBindingLocs = pELT.shouldPlotExpectedBindingLocs;
            curr_default_shouldPlotExpectedBarcodePlot = pELT.shouldPlotExpectedBarcodePlot;
            curr_default_shouldDispExpectedBarcode = pELT.shouldDispExpectedBarcode;
            curr_default_shouldSaveTxtResults = pELT.shouldSaveTxtResults;

            
            promptDialogTitle = 'Inputs for ELT';
            fnAsIs = @(x) x;
            fnLogicalScalarToYesNo = @(x) feval(@(a, b) a{b}, {'Yes'; 'No'}, 1 + (~x));
            fnIsYesStr = @(x) strcmpi(x, 'Yes') || strcmpi(x, 'Y');
            
            promptsData = {
                'bindingSequence', 'Binding sequence:', curr_default_bindingSequence, fnAsIs, fnAsIs;
                'meanBpExt_nm', 'Mean basepair extension (nm):', curr_default_meanBpExt_nm, @num2str, @str2double;
                'psfSigmaWidth_nm', 'PSF sigma width (nm):', curr_default_psfSigmaWidth_nm, @num2str, @str2double;
                'shouldPlotExpectedBindingLocs', 'Plot expected binding locs? (Yes/No)', curr_default_shouldPlotExpectedBindingLocs, fnLogicalScalarToYesNo, fnIsYesStr;
                'shouldPlotExpectedBarcodePlot', 'Plot expected barcode? (Yes/No)', curr_default_shouldPlotExpectedBarcodePlot, fnLogicalScalarToYesNo, fnIsYesStr;
                'shouldDispExpectedBarcode', 'Display expected barcode? (Yes/No)', curr_default_shouldDispExpectedBarcode, fnLogicalScalarToYesNo, fnIsYesStr;
                'shouldSaveTxtResults', 'Save results file (txt)? (Yes/No)', curr_default_shouldSaveTxtResults, fnLogicalScalarToYesNo, fnIsYesStr;
            };
        
            promptFieldnames = promptsData(:, 1);
            if any(not(cellfun(@strcmp, promptFieldnames, matlab.lang.makeUniqueStrings(matlab.lang.makeValidName(promptFieldnames)))))
                error('Invalid prompt field names');
            end
            numPrompts = size(promptsData, 1);
            
            promptDescriptions = promptsData(:, 2);
            promptDefaultVals = promptsData(:, 3);
            promptStringifyFns = promptsData(:, 4);
            promptDestringifyFns = promptsData(:, 5);
            num_lines = 1;
            defaultValStrs = cellfun(@(fnStringify, defaultVal) fnStringify(defaultVal), promptStringifyFns,  promptDefaultVals, 'UniformOutput', false);
            answersStrs = inputdlg(promptDescriptions, promptDialogTitle, num_lines, defaultValStrs);
            answers = cellfun(@(fnDestringify, answerStr) fnDestringify(answerStr), promptDestringifyFns, answersStrs, 'UniformOutput', false);

            answersStruct = struct();
            for promptNum = 1:numPrompts
                answersStruct.(promptFieldnames{promptNum}) = answers{promptNum};
            end
            
            pELT.bindingSequence = answersStruct.bindingSequence;
            pELT.psfSigmaWidth_nm = answersStruct.psfSigmaWidth_nm;
            pELT.meanBpExt_nm = answersStruct.meanBpExt_nm;
            pELT.shouldPlotExpectedBindingLocs = answersStruct.shouldPlotExpectedBindingLocs;
            pELT.shouldPlotExpectedBarcodePlot = answersStruct.shouldPlotExpectedBarcodePlot;
            pELT.shouldDispExpectedBarcode = answersStruct.shouldDispExpectedBarcode;
            pELT.shouldSaveTxtResults = answersStruct.shouldSaveTxtResults;
        end
    end
end