function [pngOutputFilepaths] = get_raw_kymo_edge_plot_png_output_filepaths(dbmODW, fileIdxs, fileMoleculeIdxs, pngOutputDirpath,timestamp)
    if nargin < 4
        defaultPngOutputDirpath = pwd();
        pngOutputDirpath = uigetdir(defaultPngOutputDirpath, 'Select png output file destination');
        if isequal(pngOutputDirpath, 0)
            pngOutputDirpath = defaultPngOutputDirpath;
        end
    end
    
    if nargin < 5
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    end
%     filename
    srcFilenames = dbmODW.get_molecule_src_filenames(fileIdxs);
    pngOutputFilenames = strcat(...
        srcFilenames,'_', timestamp,...
        '_molecule_', ...
        arrayfun(@num2str, fileMoleculeIdxs(:), 'UniformOutput', false), ...
        '.png');
    pngOutputFilepaths = fullfile(pngOutputDirpath, pngOutputFilenames);
end