function [] = export_num_iterations_as_tsv(tsvFilepathIterationsRecursive, theoryNames, theoryLengths_bp, gumbelCurveMusByIteration, gumbelCurveBetasByIteration)
    import Fancy.IO.TSV.write_tsv;

    numIterationsRecursive = max([...
        cellfun(@(r) find(diff([r, r(end)], 1, 2) == 0, 1, 'first'),...
            cellify_rows([gumbelCurveMusByIteration{:}])),...
        cellfun(@(r) find(diff([r, r(end)], 1, 2) == 0, 1, 'first'),...
            cellify_rows([gumbelCurveBetasByIteration{:}]))], [], 2);
                    
    sIterationsRecursive.theoryNames = theoryNames;
    sIterationsRecursive.theoryLengths_bp = theoryLengths_bp;
    sIterationsRecursive.numIterationsRecursive = arrayfun(@(x)x, numIterationsRecursive(:), 'UniformOutput', false);
    write_tsv(tsvFilepathIterationsRecursive, sIterationsRecursive, fields(sIterationsRecursive));
end