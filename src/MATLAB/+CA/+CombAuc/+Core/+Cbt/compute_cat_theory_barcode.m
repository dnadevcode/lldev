function [ theoryCurveUnscaled_pxRes, bitmask ] = compute_cat_theory_barcode( seq,sets )
    % Computes theory barcode for hca
    
    % input 
    % seq - sequence (oriented at human chromosomes)
    % sets - settings
    
    % output 
    % barcode
    
    % We do not want to include regions with a lot of N's, so we randomize
    % these parts. Later we could add
    seq( find(seq=='N')) = randseq(length(find(seq=='N'))); % change the unknowns into random
    
    if length(seq)<500000
        lenDiv = 7000;
    else
        lenDiv = 200000;
    end
    % we divide sequence into parts of equal length
    seqSet = {};
    if length(seq) > lenDiv+1000
        seqSet{1} = [seq(end-1000+1:end) seq(1:lenDiv+1000)];

        for i=2:(size(seq,2)-1000)/lenDiv
            seqSet{i}=seq(lenDiv*(i-1)-1000+1:lenDiv*(i)+1000);
        end
        if isempty(i)
            i=1;
        end

        seqSet{i+1} = [seq(lenDiv*(i)-1000+1:end) seq(1:1000)];
    else
        theoryCurveUnscaled_pxRes = [];
        bitmask = [];
        return;
    end
        
%     concNetropsin_molar = sets.defaultBarcodeGenSettings.concNetropsin_molar;
%     concYOYO1_molar = sets.defaultBarcodeGenSettings.concYOYO1_molar;

    numSeqs = length(seqSet);
    theoryProb_bpRes = cell(numSeqs, 1);
    %theoryFull = [];
    display('started generating theory barcode.. 0%')
  
    
    
    tic
    parfor seqNum = 1:numSeqs
        seqNum
        ntSeq = seqSet{seqNum};
        NETROPSINconc = 6;
        YOYO1conc = 4E-2;
        yoyo1BindingConstant =  sets.defaultBarcodeGenSettings.yoyo;
        %netropsinBindingConstant = [ 5E5 1E8 ];
        untrustedRegion = 1000;
        W = 100.0;
        S = 8.0;
        netropsinBindingConstant = [S^4 W*S^3 (S^2)*(W^2) S*W^3 W^4]./1E6;
        % compute Netropsin & YOYO-1 binding probabilities
        probsBinding = CA.CombAuc.Core.Cbt.cb_transfer_matrix_editable(ntSeq,NETROPSINconc,YOYO1conc,yoyo1BindingConstant,netropsinBindingConstant, untrustedRegion);
%        import CBT.Core.cb_netropsin_vs_yoyo1_plasmid;
%         probsBinding = cb_netropsin_vs_yoyo1_plasmid(ntSeq, concNetropsin_molar,  concYOYO1_molar);

        % YOYO-1 binding probabilities
   %    theoryProb_bpRes{seqNum} = probsBinding.Yoyo1';
       theoryProb_bpRes{seqNum} = probsBinding;

       % spool(seqNum) = 0;
       % procDone = (1-sum(spool)/length(spool))*100;
       % display(strcat(['done generating theory barcode... ' num2str(procDone) '%']))
    end
    display('done generating theory barcode... 100%')
    toc
    clear seqSet
   % delete(gcp)

    import Microscopy.Simulate.Core.apply_point_spread_function;
    psfSigmaWidth_bps = sets.barcodeConsensusSettings.psfSigmaWidth_nm / sets.meanBpExt_nm;

    import CBT.Core.convert_bpRes_to_pxRes;
    meanBpExt_pixels = sets.meanBpExt_nm / sets.barcodeConsensusSettings.prestretchPixelWidth_nm;

   % isLinearTF = sets.isLinearTF;
   % widthSigmasFromMean = sets.barcodeConsensusSettings.deltaCut;

  
  % theoryBar_bpRes = cell(numSeqs, 1);
   %seqNces = round(length(theoryProb_bpRes)/4);
   %len1=1:seqNces;
   
    import CA.CombAuc.Core.Zeromodel.gaussian_kernel;
    ker = gaussian_kernel(length(theoryProb_bpRes{1}), psfSigmaWidth_bps);
    multF=conj(fft(ker))';

    
    probSeq = zeros(1,length(seq));
    
    for i=1:length(theoryProb_bpRes)-1
        theoryBar_bpRes = ifft(fft(theoryProb_bpRes{i}).*multF); 
        probSeq(1+(i-1)*lenDiv:(i)*lenDiv) = theoryBar_bpRes(1001:end-1000);
    end
    
    ker = gaussian_kernel(length(theoryProb_bpRes{end}), psfSigmaWidth_bps);
    multF=conj(fft(ker))';
    theoryBar_bpRes = ifft(fft(theoryProb_bpRes{end}).*multF); 
    probSeq((length(theoryProb_bpRes)-1)*lenDiv+1:end) = theoryBar_bpRes(1001:end-1000);
    
    theoryCurveUnscaled_pxRes = convert_bpRes_to_pxRes(probSeq, meanBpExt_pixels);

    bitmask = ones(1,length(theoryCurveUnscaled_pxRes));
end

