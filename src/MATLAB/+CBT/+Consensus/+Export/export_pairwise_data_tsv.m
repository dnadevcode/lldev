function [dataFieldTablesStruct, dataFieldMatsStruct, freshlyCalculatedMat] = export_pairwise_data_tsv(mode, dataFieldNames, consensusMatFilepath)
    dataFieldTablesStruct = struct();
    dataFieldMatsStruct = struct();
    freshlyCalculatedMat = [];

    if nargin < 1
        mode = '';
    end
    if nargin < 2
        dataFieldNames = [];
    end
    if nargin < 3
        consensusMatFilepath = [];
    end

    shouldDisplayVerbosely = strcmp(mode, 'verbose');
    possibleDataFieldNames =  {'bestScore'; 'xcorrAtBest'; 'flipTFAtBest'; 'circShiftAtBest'};
    if isempty(dataFieldNames)
        dataFieldNames = [possibleDataFieldNames; {'+aliases'}];
    elseif ischar(dataFieldNames)
        dataFieldNames = {dataFieldNames};
    end

    tmp = cellfun(@(s)strcmp(s,'+aliases'), dataFieldNames);
    printAliases = any(tmp);
    dataFieldNames = dataFieldNames(~tmp);
    dataFieldNames = intersect(dataFieldNames, possibleDataFieldNames);
    import CBT.Consensus.Export.Helper.get_default_consensus_dirpath;
    if isempty(consensusMatFilepath)
        defaultConsensusDirpath = get_default_consensus_dirpath();
        [consensusFilename, consensusDirpath] = uigetfile('*.mat', 'Load Automatic Consensus Cluster Data As', defaultConsensusDirpath);
        if isequal(consensusDirpath, 0)
            disp('Cancelled file selection');
            return;
        end
        consensusMatFilepath = fullfile(consensusDirpath, consensusFilename);
    end
    tmp = load(consensusMatFilepath);
    clusterConsensusData = tmp.clusterConsensusData;

    barcodeAliasesCellArr = clusterConsensusData.details.consensusStruct.inputs.barcodeAliases;
    barcodeLabels = arrayfun(@(x)['Barcode_', num2str(x)], (1:numel(barcodeAliasesCellArr))', 'UniformOutput', false);

    [consensusDirpath, consensusFilename, ~] = fileparts(consensusMatFilepath);

    consensusStruct = clusterConsensusData.details.consensusStruct;
    [dataFieldMatsStruct, freshlyCalculatedMat, ~] = CMN_Consensus.get_pairwise_values(dataFieldNames, consensusStruct, true);



    aliasesTable = array2table(barcodeAliasesCellArr,'RowNames',barcodeLabels,'VariableNames',{'Aliases'});
    dataFieldTablesStruct.ALIASES = aliasesTable;
    if printAliases
        defaultAliasTableFilename = sprintf('%s_aliases.tsv', consensusFilename);
        defaultAliasTableFilepath = fullfile(consensusDirpath, defaultAliasTableFilename);
        [aliasTableFilename, aliasTableDirpath] = uiputfile('*.tsv', 'Save Alias Table As', defaultAliasTableFilepath);
        if aliasTableDirpath ~= 0
            aliasTableFilepath = fullfile(aliasTableDirpath, aliasTableFilename);
            writetable(aliasesTable, aliasTableFilepath,'Delimiter','\t','WriteRowNames',true,'FileType','text')
        end
        if shouldDisplayVerbosely
            disp('ALIASES:');
            disp(aliasesTable);
        end
    end

    numDataFields = numel(dataFieldNames);
    defaultFieldTsvDirpath = consensusDirpath;
    for dataFieldNum = 1:numDataFields
        dataFieldName = dataFieldNames{dataFieldNum};
        dataFieldMat = dataFieldMatsStruct.(dataFieldName);
        dataTable = array2table(dataFieldMat, 'RowNames', barcodeLabels, 'VariableNames', barcodeLabels);

        defaultFieldTsvFilename = sprintf('%s_%s.tsv', consensusFilename, dataFieldName);
        fieldTsvFilepath = fullfile(defaultFieldTsvDirpath, defaultFieldTsvFilename);
        [fieldTsvFilename, fieldTsvDirpath, ~] = uiputfile('*.tsv',['Save ''', dataFieldName, ''' Data As'], fieldTsvFilepath);
        if fieldTsvDirpath ~= 0
            fieldTsvFilepath = fullfile(fieldTsvDirpath, fieldTsvFilename);
            writetable(dataTable, fieldTsvFilepath, 'Delimiter', '\t', 'WriteRowNames', true, 'FileType', 'text');
        end

        dataFieldTablesStruct.(dataFieldName) = dataTable;
        if shouldDisplayVerbosely
            fprintf('%s:\n', dataFieldName);
            disp(dataTable);
        end
    end
end