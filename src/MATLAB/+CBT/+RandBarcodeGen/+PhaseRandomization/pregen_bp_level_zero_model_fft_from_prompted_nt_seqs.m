 function [] = pregen_bp_level_zero_model_fft_from_prompted_nt_seqs(sets)
    % pregen_bp_level_zero_model_fft_from_prompted_nt_seqs
    % This function pre-generated zero model for sequence comparison, but
    % it does so in the bp-level, as opposed to the other method, which
    % does so in px resolution (and then need to interpolate each time we
    % want to change the resolution)
    
    % The standard input is the sets file, but this can be skipped and all
    % the options can be made to be user selectable
    
    if nargin < 1
        % sets were not initialized yet, initialize settings
        
        % add later choice for settings..
        %sets = [];
        
        % defaults
        minSeqLength = 1000;
        NETROPSINconc = 6;
        YOYO1conc = 0.02;
        concDNA = 2;
        untrustedRegion = 1000;
        import CBT.Core.choose_model;
        model = choose_model('literature');
    end
    
    
    % First, select sequence files
    
    % Newest sequences can be downloaded from 
    % ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/plasmid/
    import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
    [aborted, fastaFilepaths] = try_prompt_nt_seq_filepaths([], [], false);


    if aborted || isempty(fastaFilepaths)
        fprintf('No sequences were provided\n');
        return;
    end
    
     disp('Started generating a zero-model fft at bp level...\n');

    
    import NtSeq.Import.import_fasta_nt_seqs;

    lens = cell(1,length(fastaFilepaths));
    % run each file separately so as not to overload memory
    for i=1:length(fastaFilepaths)
        % Load sequencies
        ntSeqs = import_fasta_nt_seqs(fastaFilepaths{i});
        % compute lengths
        lens{i} = cellfun(@length, ntSeqs);
    end
    
    % find the longest sequence in each file
    maxL = cellfun(@max,lens);

    % find the number of sequences above min sequence length, which here is set to
    % minSeqLength=1000
    nInd = 0;
    for i=1:length(lens)
        nInd = nInd+sum(lens{i}>minSeqLength);
    end
    
    % find the longest sequence
    maxLength = max(maxL);

    prob = cell(1,length(listing)-2);
    meanFFTSquared = zeros(1,maxLength);

    % now run the computation
    for i=1:length(fastaFilepaths)
     	ntSeqs = import_fasta_nt_seqs(fastaFilepaths{i});
        ntSeqs(find(lens{i-2}<=1000)) = [];
        prob{i-2}.prb = cell(1,length(ntSeqs));

        for j=1:length(ntSeqs)
            prob{i-2}.prb{j} = CA.CombAuc.Core.Cbt.cb_transfer_matrix_literature(ntSeqs{j}, concNetropsin_molar, concYOYO1_molar, model.yoyo1BindingConstant,model.values, untrustedRegion);
        end
         import CBT.RandBarcodeGen.PhaseRandomization.gen_mean_fft_at_bp_res;
        [ meanFFTS, ~, ~, ~]= gen_mean_fft_at_bp_res(prob{i-2}.prb, maxLength, nInd);
        meanFFTSquared = meanFFTSquared+meanFFTS;
    end
    
    meanFFTEst = sqrt(meanFFTSquared);

    import CBT.RandBarcodeGen.PhaseRandomization.export_fft_file;
    export_fft_file(meanFFTEst, 0.001);

    fprintf('Finished generating Zero model fft from sequences\n')
 end