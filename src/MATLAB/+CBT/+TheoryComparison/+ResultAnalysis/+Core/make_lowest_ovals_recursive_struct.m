function [lowestOValsRecursiveStruct, recursiveFields] = make_lowest_ovals_recursive_struct(theoryNames, theoryLengths_bp, outlierScoresMatrixRecursiveLowest)
    lowestOValsRecursiveStruct.theoryNames = theoryNames;
    lowestOValsRecursiveStruct.theoryLengths_bp = theoryLengths_bp;
    recursiveFields = cell(nLowest, 1);
    for k=1:nLowest 
        recursiveFields{k} = sprintf('oValRecursiveLowest%d', k);
        lowestOValsRecursiveStruct.(recursiveFields{k}) = outlierScoresMatrixRecursiveLowest(k, :);
    end
    recursiveFields = [{'theoryNames'; 'theoryLengths_bp'}; recursiveFields];
end