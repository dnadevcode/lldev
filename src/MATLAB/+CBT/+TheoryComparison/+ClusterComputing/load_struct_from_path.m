function theoryStruct = load_struct_from_path(theorySequenceFilepath, permanentCurvesDirpath, cacheSubdirname, cacheResultsSubdirname)
        import Fancy.Utils.data_hash;

        import NtSeq.Import.try_import_fasta_nt_seq;
        [~, ntSeq] = try_import_fasta_nt_seq(theorySequenceFilepath);
        sequenceLength = length(ntSeq);
        dataHash = data_hash(ntSeq);
        CBT_TheoryComparison.mkdir_if_not_exist(fullfile(permanentCurvesDirpath, cacheSubdirname, cacheResultsSubdirname));
        cacheFilepath = fullfile(permanentCurvesDirpath, cacheSubdirname, [dataHash, '.mat']);

        theoryStruct.sourceFilepath = theorySequenceFilepath;
        theoryStruct.sequenceData = ntSeq;
        theoryStruct.dataHash = dataHash;
        theoryStruct.sequenceLength = sequenceLength;
        theoryStruct.cacheFilepath = cacheFilepath;
        bitmaskACTG = (ntSeq == double('A')) | (ntSeq == double('C')) | (ntSeq == double('T')) | (ntSeq == double('G'));
        theoryStruct.nonACTG = ~bitmaskACTG;
        theoryStruct.nonACTG_length = sum(theoryStruct.nonACTG);
        theoryStruct.nonACTG = theoryStruct.sequenceData(theoryStruct.nonACTG);
        % theory_curve_bpRes = CBT_TheoryComparison.get_struct_theory_curve_bpRes(theoryStruct);
        % theoryStruct = rmfield(theoryStruct, 'sequenceData');
        % theoryStruct.theoryCurve_bpRes_prePSF = theory_curve_bpRes;
end
