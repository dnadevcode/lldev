function [onlyAValues, onlyBValues, intersectionValues, unionValues] = diff_unique_sorted_vectors(aValues, bValues)
    if ((not(isvector(aValues)) && not(isempty(aValues))) || any(diff(aValues) <= 0)) || ((not(isvector(bValues)) && not(isempty(bValues))) || any(diff(bValues) <= 0))
        error('Inputs must be vectors of unique, ascending (sorted), numeric values');
    end
    % Should be equivalent to setdiff, intersection, union, but
    %   faster for large vectors since we know that
    %   the inputs are vectors with only unique, ascending values

    nA = length(aValues);
    nOnlyA = 0;
    onlyAValues = zeros(nA, 1);

    nB = length(bValues);
    nOnlyB = 0;
    onlyBValues = zeros(nB, 1);

    nIntersection = 0;
    intersectionValues = zeros(min(nA, nB), 1);

    nUnion = 0;
    unionValues = zeros(max(nA, nB), 1);

    iA = 1;
    iB = 1;
    while true
        if (iA <= nA)
            vA = aValues(iA);
        else
            vA = Inf;
        end
        if (iB <= nB)
            vB = bValues(iB);
        else
            vB = Inf;
        end

        if (vA == vB)
            if vA == Inf
                break; % done
            end
            nIntersection = nIntersection + 1;
            nUnion = nUnion + 1;
            intersectionValues(nIntersection) = vA;
            unionValues(nUnion) = vA;
            iA = iA + 1;
            iB = iB + 1;
        elseif (vA < vB)
            nOnlyA = nOnlyA + 1;
            nUnion = nUnion + 1;
            onlyAValues(nOnlyA) = vA;
            unionValues(nUnion) = vA;
            iA = iA + 1;
        else % vB < vA
            nOnlyB = nOnlyB + 1;
            nUnion = nUnion + 1;
            onlyBValues(nOnlyB) = vB;
            unionValues(nUnion) = vB;
            iB = iB + 1;
        end
    end

    onlyAValues = onlyAValues(1:nOnlyA);
    onlyBValues = onlyBValues(1:nOnlyB);
    intersectionValues = intersectionValues(1:nIntersection);
    unionValues = unionValues(1:nUnion);
end
