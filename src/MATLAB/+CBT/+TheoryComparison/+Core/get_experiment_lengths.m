function experimentLengths_nm = get_experiment_lengths(experimentStructs, pixelWidth_nm)
    import CBT.TheoryComparison.Core.get_experiment_length;

    numExperiments = length(experimentStructs);
    experimentLengths_nm = zeros(numExperiments, 1);
    for experimentNum = 1:numExperiments
        experimentLengths_nm(experimentNum) = get_experiment_length(experimentStructs{experimentNum}, pixelWidth_nm);
    end
end