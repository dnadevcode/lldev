function [firstProbsVect, lastProbsVect, probBindingsDepadded, probBindingsPaddingFront, probBindingsPaddingBack] = test_cbt_with_rand_margins(ntSeq, numIterations, untrustedMarginActualWithRand, concNetropsin_molar, concYOYO1_molar)
    % Just a test Chris Pichler wanted on how using random
    % nucleotides instead of nucleotides from the other end
    % of a nucleotide sequence effected computations for
    % competitive binding at the edges of the theory barcode produced
    % (since wrap-around doesn't quite make sense for linear DNA)

    
    if nargin < 1
        import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
        % appDir = pwd();
        % defaultFastaFilepath = fullfile(fileparts(appDir), 'contig', 'R100_seq_04_contigs_100.fasta');
        % [aborted, ntSeqFilepaths] = try_prompt_nt_seq_filepaths([], false, true, defaultFastaFilepath);
        [aborted, ntSeqFilepaths] = try_prompt_nt_seq_filepaths([], false, true);
        if aborted || isempty(ntSeqFilepaths)
            error('No theory sequence was provided');
        end
        
        import NtSeq.Import.import_fasta_nt_seqs;
        ntSeqs = import_fasta_nt_seqs(ntSeqFilepaths{1});
        ntSeq = ntSeqs{1};
    end
    if nargin < 2
        numIterations = 10000;
    end
    if nargin < 3
        untrustedMarginActualWithRand = 1000;
    end
    if nargin < 4
        concNetropsin_molar = 20e-6;
    end
    if nargin < 5
        concYOYO1_molar = 0.20e-6;
    end
    import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
    
    onlyYoyo1Prob = true;
    roundingPrecision = 8;
    untrustedMarginPassed = 0;
    
    firstProbsVect = NaN(numIterations, 1);
    lastProbsVect = NaN(numIterations, 1);
    probBindingsDepadded = cell(numIterations, 1);
    probBindingsPaddingFront = cell(numIterations, 1);
    probBindingsPaddingBack = cell(numIterations, 1);
    for iterationNum = 1:numIterations
        paddedNtSeq = [int2nt(ceil(rand(1,untrustedMarginActualWithRand).*4)), ntSeq, int2nt(ceil(rand(1, untrustedMarginActualWithRand).*4))];
        probBindingPadded = CBT.Core.cb_netropsin_vs_yoyo1_plasmid(paddedNtSeq, concNetropsin_molar, concYOYO1_molar, untrustedMarginPassed, onlyYoyo1Prob, roundingPrecision);

        probBindingDepadded = probBindingPadded(untrustedMarginActualWithRand + (1:length(ntSeq)));
        firstProbsVect(iterationNum) = probBindingDepadded(1);
        lastProbsVect(iterationNum) = probBindingDepadded(end);

        probBindingsPaddingFront{iterationNum} = probBindingPadded(1:untrustedMarginActualWithRand);
        probBindingsPaddingBack{iterationNum} = probBindingPadded((1:untrustedMarginActualWithRand) + (untrustedMarginActualWithRand + length(ntSeq)));
        probBindingsDepadded{iterationNum} = probBindingDepadded;
    end
end