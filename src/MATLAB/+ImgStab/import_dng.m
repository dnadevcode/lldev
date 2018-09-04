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
            error('Please follow the instructions in Windows_README.txt to compile dcraw.exe');
        else
            dcrawProgram = dcrawPath;
        end
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
    end
    sysCmdTxtConvertDngToTiff = sprintf('%s -D -T -6 "%s"', dcrawProgram, dngFilepath);
    system(sysCmdTxtConvertDngToTiff);
    bayerI = imread(tiffFilepath);
    rgbI = demosaic(bayerI, bayerPattern);
end