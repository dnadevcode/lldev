function [ theoryCurveUnscaled_pxRes, bitmask, probSeq,theorSeq] = compute_hca_theory_barcode( seq,sets, overlapLength )
    % Computes theory barcode for hca
    
    % input 
    % seq - sequence (oriented at human chromosomes)
    % sets - settings
    
    % output 
    % barcode
    
    if nargin < 3
        overlapLength = 3000;
    end
    
    % find bp positions where the letters are undefined or unknown, these
    % will be converted to bitmask later
    undefinedBasepairs = ones(1,length(seq));
    positions = find(seq=='N');
    undefinedBasepairs(positions) = zeros(1,length(positions));
    
    % We do not want to include regions with a lot of N's, so we randomize
    % these parts. Later we could add
    if sets.isLinearTF
        seq = [repmat('A',1,10000) seq repmat('A',1,10000)];
    end
    
    % change the bp with unknown letters into random letters (for better
    % barcodes close to unknown positions
    seq(positions) = randseq(length(positions)); % change the unknowns into random
    
    if length(seq)< 500000
        overlapLength = 0;
        lenDiv = length(seq);
    else
        lenDiv = 200000;
    end
    % we divide sequence into parts of equal length
    seqSet = cell(1,ceil((size(seq,2)-overlapLength)/lenDiv));
    
    seqSet{1} = [seq(end-overlapLength+1:end) seq(1:lenDiv+overlapLength)];


    for i=2:(size(seq,2)-overlapLength)/lenDiv
        seqSet{i}=seq(lenDiv*(i-1)-overlapLength+1:lenDiv*(i)+overlapLength);
    end
    
    if overlapLength ~= 0
        seqSet{i+1} = [seq(lenDiv*(i)-overlapLength+1:end) seq(1:overlapLength)];
    end
    
    concNetropsin_molar = sets.concNetropsin_molar;
    concYOYO1_molar = sets.concYOYO1_molar;
    untrustedRegion = 1000;
    import CBT.BC.Core.choose_model;
    model = choose_model('literature');
    values = model.netropsinBindingConstant;
    yoyo1BindingConstant = model.yoyo1BindingConstant;
    numSeqs = length(seqSet);
    theoryProb_bpRes = cell(numSeqs, 1);
    %theoryFull = [];
    disp('started generating theory barcode.. 0%')
    
    tic
    parfor seqNum = 1:numSeqs
        ntSeq = seqSet{seqNum};

        % compute Netropsin & YOYO-1 binding probabilities
        probsBinding = CA.CombAuc.Core.Cbt.cb_transfer_matrix_literature(ntSeq, concNetropsin_molar,  concYOYO1_molar,yoyo1BindingConstant,values, untrustedRegion);
%         import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
%         probsBinding = cb_netropsin_vs_yoyo1_plasmid(ntSeq, concNetropsin_molar,  concYOYO1_molar);

        % YOYO-1 binding probabilities
        theoryProb_bpRes{seqNum} = probsBinding';
        
    end
    disp('done generating theory barcode... 100%')
    toc
    clear seqSet
   % delete(gcp)

   % alternative 
  % [theoryCurveUnscaled_pxRes,bitmask] = compute_theory_in_nm(sets,theoryProb_bpRes,seq,overlapLength,lenDiv,undefinedBasepairs);
   
  %  import Microscopy.Simulate.Core.apply_point_spread_function;
    psfSigmaWidth_bps = sets.psfSigmaWidth_nm / sets.meanBpExt_nm;

    import CBT.Core.convert_bpRes_to_pxRes;
    meanBpExt_pixels = sets.meanBpExt_nm / sets.pixelWidth_nm;

    %isLinearTF = sets.isLinearTF;
   % widthSigmasFromMean = sets.widthSigmasFromMean;

  
   %theoryBar_bpRes = cell(numSeqs, 1);
   %seqNces = round(length(theoryProb_bpRes)/4);
   %len1=1:seqNces;
   
    import CA.CombAuc.Core.Zeromodel.gaussian_kernel;
    ker = gaussian_kernel(length(theoryProb_bpRes{1}), psfSigmaWidth_bps);
    multF=conj(fft(ker));

    
    probSeq = zeros(1,length(seq));
    
    theorSeq = zeros(1,length(seq));

    for i=1:length(theoryProb_bpRes)-1
        theoryBar_bpRes = ifft(fft(theoryProb_bpRes{i}).*multF); 
        probSeq(1+(i-1)*lenDiv:(i)*lenDiv) = theoryBar_bpRes(overlapLength+1:end-overlapLength);
        theorSeq(1+(i-1)*lenDiv:(i)*lenDiv) = theoryProb_bpRes{i}(overlapLength+1:end-overlapLength);
    end
    
    ker = gaussian_kernel(length(theoryProb_bpRes{end}), psfSigmaWidth_bps);
    multF=conj(fft(ker));
    theoryBar_bpRes = ifft(fft(theoryProb_bpRes{end}).*multF); 
    probSeq((length(theoryProb_bpRes)-1)*lenDiv+1:end) = theoryBar_bpRes(overlapLength+1:end-overlapLength);
    theorSeq((length(theoryProb_bpRes)-1)*lenDiv+1:end) = theoryProb_bpRes{end}(overlapLength+1:end-overlapLength);

    if sets.isLinearTF
    	probSeq = probSeq(10001:end-10000);
        theorSeq = theorSeq(10001:end-10000);
    end
    
    % pixel resoution barcode
    theoryCurveUnscaled_pxRes = convert_bpRes_to_pxRes(probSeq, meanBpExt_pixels);
    
    % todo: make this more accurate by allowing a % (1%?) of unknown
    % letters
    bitmask = undefinedBasepairs(round(1:1/meanBpExt_pixels:length(undefinedBasepairs)));
end

