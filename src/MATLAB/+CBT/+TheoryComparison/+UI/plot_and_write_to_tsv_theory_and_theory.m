function [] = plot_and_write_to_tsv_theory_and_theory(hAxis, thyStructA, thyStructB, stretchFactor, settingsParams, columnLabels)
    defaultColumnLabels = {'curveA', 'curveB'};
    if nargin < 6
        columnLabels = defaultColumnLabels;
    end
    [tsvFilename, tsvDirpath] = uiputfile({'.tsv'});

    if isequal(tsvDirpath, 0)
        return;
    end

    import CBT.TheoryComparison.UI.plot_theory_and_theory;
    dataStruct = plot_theory_and_theory(hAxis, thyStructA, thyStructB, stretchFactor, settingsParams);
    dataStruct2 = struct;
    numDefaultColumnLabels = length(defaultColumnLabels);
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