function [centerOfMassTable] = disp_raw_kymos_centers_of_mass(dbmODW, dbmOSW, writeToTSV)
    if nargin < 3
        writeToTSV = true;
    end

    import OldDBM.Kymo.Core.calc_raw_kymos_centers_of_mass;
    [centerOfMassTable] = calc_raw_kymos_centers_of_mass(dbmODW);
    disp(centerOfMassTable);

    if writeToTSV
        timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
        defaultOutputDirpath = dbmOSW.get_default_export_dirpath('raw_kymo_center_of_mass');
        defaultOutputFilename = sprintf('centerOfMassTable_%s.tsv', timestamp);
        defaultOutputFilepath = fullfile(defaultOutputDirpath, defaultOutputFilename);

        [outputFilename, outputDirpath] = uiputfile('*.tsv', 'Save Centers of Mass As', defaultOutputFilepath);

        if isequal(outputDirpath, 0)
            return;
        end
        outputFilepath = fullfile(outputDirpath, outputFilename);

        writetable(centerOfMassTable, outputFilepath, ...
            'Delimiter', sprintf('\t'), ...
            'FileType', 'text');
    end
end