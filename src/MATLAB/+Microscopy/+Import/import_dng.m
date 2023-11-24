function [rgbI, bayerI, dngFilepath, tiffFilepath, bayerPattern] = import_dng(sourcePath)
    if nargin < 1
        sourcePath = [];
    end
    
    if not(isempty(sourcePath)) && (exist(sourcePath, 'file') == 2)
        [~, ~, ext] = fileparts(sourcePath);
        if strcmpi(ext, '.dng')
            dngFilepath = sourcePath;
        end
    else
        import ImgStab.prompt_dng_filepaths;
        dngFilepath = prompt_dng_filepaths(sourcePath);
    end

    if isempty(dngFilepath)
        bayerI = zeros(0, 0, 1);
        rgbI = zeros(0, 0, 3);
        return;
    end
    import Microscopy.Import.get_dng_cfa_bayer_pattern;
    bayerPattern = get_dng_cfa_bayer_pattern(dngFilepath);
    if isempty(bayerPattern)
        error('Bayer pattern for ''%s'' could not be detected', dngFilepath);
    end
    [dirpath, dngFilenameSansExt, ~] = fileparts(dngFilepath);
    tiffFilepath = fullfile(dirpath, [dngFilenameSansExt, '.tiff']);
    dcrawProgram = 'dcraw';
    import Fancy.AppMgr.AppResourceMgr;
    appRsrcMgr = AppResourceMgr.get_instance();
    appDirpath = appRsrcMgr.get_app_dirpath();
    if ispc
        dcrawPath = fullfile(appDirpath, 'bin', [dcrawProgram, '.exe']);
        if not(exist(dcrawPath, 'file'))
            try
                cDcrawPath = fullfile(appDirpath, 'src', 'C', 'ThirdParty', 'dcraw', 'dcraw.c');
                if exist(cDcrawPath, 'file')
                    outPathDosEscaped = dos_escape_path(dcrawPath);
                    inPathDosEscaped = dos_escape_path(cDcrawPath);
                    
                    sysCmdTxtCompileC = sprintf('gcc -o %s -O3 %s -lm -DNODEPS  -lws2_32', outPathDosEscaped, inPathDosEscaped);
                    fprintf('Attempting to compile dcraw.c to bin\n');
                    [~,~,~] = evalc(sprintf('system(''%s'');', sysCmdTxtCompileC));
                    fprintf('Completed compilation attempt\n');
                end
            catch
            end
            if exist(dcrawPath, 'file')
                dcrawProgram = dcrawPath;
            else
                error('Please follow the instructions in Windows_README.txt to compile dcraw.exe');
            end
        else
            dcrawProgram = dcrawPath;
        end
        sysCmdTxtConvertDngToTiff = sprintf('%s -D -T -6 "%s"', dos_escape_path(dcrawProgram), dos_escape_path(dngFilepath));
    elseif isunix
        dcrawPath = fullfile(appDirpath, 'bin', dcrawProgram);
        if not(exist(dcrawPath, 'file'))
            makeDcrawScriptFilepath = fullfile(appDirpath, 'src', 'sh', 'linux_compile_dcraw.sh');
            if exist(makeDcrawScriptFilepath, 'file')
                try
                    sysCmdTxtChmod = sprintf('chmod u+x %s', makeDcrawScriptFilepath);
                    sysCmdTxtRunBash = sprintf('%s', makeDcrawScriptFilepath);
                    system(sysCmdTxtChmod);
                    system(sysCmdTxtRunBash);
                catch
                end
            end
        end
        if exist(dcrawPath, 'file')
            dcrawProgram = dcrawPath;
        end
        sysCmdTxtConvertDngToTiff = sprintf('%s -D -T -6 "%s"', dcrawProgram, dngFilepath);
    end
    system(sysCmdTxtConvertDngToTiff);
    bayerI = imread(tiffFilepath);
    rgbI = demosaic(bayerI, bayerPattern);
    

    function dosEscapedPath = dos_escape_path(path)
        tmpEsc = {'"'; ''};
        dosEscapedPath = strsplit(path, filesep());
        dosEscapedPath = strjoin(arrayfun(...
        @(idx, escapeTF) ...
            [tmpEsc{2 - escapeTF}, dosEscapedPath{idx}, tmpEsc{2 - escapeTF}], ...
            (1:length(dosEscapedPath))', ...
            cellfun(@(s) any(isspace(s)), dosEscapedPath(:)), ...
            'UniformOutput', false), filesep());
    end
end