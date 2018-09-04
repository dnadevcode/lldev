function indices = minimize_local_index_similarity(indices)
    import CBT.TheoryComparison.ClusterComputing.middle_first_sort;
    n = length(indices);
    if n < 2
        return;
    end
    indices = [indices(n), indices(1), middle_first_sort(indices(2:(n-1)))];
end