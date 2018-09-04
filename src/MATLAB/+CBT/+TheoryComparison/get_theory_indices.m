function [foundTheoryIndices, foundTheoryNames, missingTheoryNames] = get_theory_indices(theoryNames, theoryNamesSearched)
    theoryNames = theoryNames(:);
    theoryNamesSearched = theoryNamesSearched(:);
    [foundTheoryNames, foundTheoryIndices] = intersect(theoryNames, theoryNamesSearched);
    missingTheoryNames = setdiff(theoryNamesSearched, foundTheoryNames);
    if not(isempty((missingTheoryNames)))
        strMissingTheories = strjoin([{'_'}, missingTheoryNames', {'_'}], ''', ''');
        strMissingTheories = strMissingTheories(5:end-4);
        warning(['Some theories not found:', strMissingTheories]);
    end
end