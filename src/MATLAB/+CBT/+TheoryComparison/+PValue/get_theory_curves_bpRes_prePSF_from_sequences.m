function [theoryCurves_bpRes_prePSF] = get_theory_curves_bpRes_prePSF_from_sequences(theorySequences, concNetropsin_molar, concYOYO1_molar)
    numSequences = length(theorySequences);
    fprintf('Generating %d basepair-resolution theory curves from sequences...\n', numSequences);
    theoryCurves_bpRes_prePSF = cell(numSequences, 1);
    percentProgressLastReported = 0;
    percentProgressReportInterval = 1;
    import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
    for sequenceNum = 1:numSequences
        theoryCurve_bpRes_prePSF = cb_netropsin_vs_yoyo1_plasmid(theorySequence, concNetropsin_molar, concYOYO1_molar, [], true);
        theoryCurves_bpRes_prePSF{sequenceNum} = theoryCurve_bpRes_prePSF;
        percentProgress = floor(100*sequenceNum/numSequences);
        if (percentProgress == 100) || (percentProgress >= percentProgressLastReported + percentProgressReportInterval)
            percentProgressLastReported = percentProgress;
            fprintf('  Generating basepair-resolution theory curves %d%% complete...\n', percentProgress);
            if (percentProgress == 100)
                fprintf('  Done generating %d  basepair-resolution theory curves\n', sequenceNum);
            end
        end
    end
end