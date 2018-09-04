function [lowestOValsNonrecursiveStruct, nonrecursiveFields] = make_lowest_ovals_nonrecursive_struct(theoryNames, theoryLengths_bp, outlierScoresMatrixNonrecursiveLowest)
    lowestOValsNonrecursiveStruct.theoryNames = theoryNames;
    lowestOValsNonrecursiveStruct.theoryLengths_bp = theoryLengths_bp;
    nonrecursiveFields = cell(nLowest, 1);
    for k=1:nLowest
        nonrecursiveFields{k} = sprintf('oValNonrecursiveLowest%d', k);
        lowestOValsNonrecursiveStruct.(nonrecursiveFields{k}) = outlierScoresMatrixNonrecursiveLowest(k, :);
    end
    nonrecursiveFields = [{'theoryNames'; 'theoryLengths_bp'}; nonrecursiveFields];
end