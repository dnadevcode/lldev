function [] = plot_and_write_to_tsv_theory_and_experiment(hAxis, thyStruct, expStruct, stretchFactor, settingsParams, columnLabels)
    
    defaultColumnLabels = {'curveA', 'curveB'};
    if nargin < 5
        columnLabels = defaultColumnLabels;
    end
    columnLabels = columnLabels(1:length(defaultColumnLabels));
    [tsvFilename, tsvDirpath] = uiputfile({'.tsv'});

    if isequal(tsvDirpath, 0)
        return;
    end

    import CBT.TheoryComparison.UI.plot_theory_and_experiment;
    dataStruct = plot_theory_and_experiment(hAxis, thyStruct, expStruct, stretchFactor, settingsParams);
    dataStruct2 = struct;
    numDefaultColumnLabels=length(defaultColumnLabels);
    for defaultColumnLabelNum=1:numDefaultColumnLabels
        defaultColumnLabel = defaultColumnLabels{defaultColumnLabelNum};
        columnLabel = defaultColumnLabel;
        if length(columnLabels) >= defaultColumnLabelNum
            columnLabel = columnLabels{defaultColumnLabelNum};
        end
        dataStruct2.(columnLabel) = dataStruct.(defaultColumnLabel);
    end
    
    import Fancy.IO.TSV.write_tsv;
    write_tsv([tsvDirpath, tsvFilename], dataStruct2, columnLabels);
end