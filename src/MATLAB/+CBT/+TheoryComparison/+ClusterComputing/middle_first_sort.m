function indices = middle_first_sort(indices)
    import CBT.TheoryComparison.ClusterComputing.middle_first_sort;
    n = length(indices);
    if (n < 3);
        return;
    end
    m = ceil((n + 1)/2);
    leftIndices = middle_first_sort(indices(1:(m-1)));
    lenLeft = length(leftIndices);
    rightIndices = middle_first_sort(indices((m+1):n));
    lenRight = length(rightIndices);

    tmp = nan(2, max(lenLeft, lenRight));
    tmp(1,1:lenLeft) = leftIndices;
    tmp(2,1:lenRight) = rightIndices;
    tmp = tmp(:)';
    tmp = tmp(~isnan(tmp));

    indices = [indices(m), tmp];
end