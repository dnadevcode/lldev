function [orderedExperimentLengths, orderedExperimentIndices] = get_length_ordering_for_experiments(experimentStructs, nmPerPixel)
    import CBT.TheoryComparison.Core.get_experiment_lengths;

    experimentLengths = get_experiment_lengths(experimentStructs, nmPerPixel);
    [orderedExperimentLengths, orderedExperimentIndices] = sort(experimentLengths);
end