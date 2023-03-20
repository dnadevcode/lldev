function [dataStorage, nmbpHist, lambdaLen] = compare_lambda_to_theory(barcodeGen,bgMean,curSetsNMBP, NN, stretchFactors, nmPx,nmPsf, BP, threshScore , atPref)
    
    %   Args:
    %       barcodeGen - barcodes to analyze
    %       bgMean - background mean
    %       curSetsNMBP - initial nm to bp ratio
    %       NN - how many iterations to run
    %       stretchFactors - length re-scaling factors to try
    %       nmPx - nanometers per pixel
    %       BP - basepairs at the side of lambda theory
    %       threshScore - threshscore for good comparison

    %   Returns:
    %       lambdaLen
   
    import DBM4.LambdaDet.gcweighted; % quick way to compare weighted GC

    if nargin < 3

        curSetsNMBP = 0.22; %
        %
        NN = 10;
        stretchFactors = 0.7:0.01:1.3;
        %     sets.theoryGen.pixelWidth_nm = 254;
        nmPsf = 300;
        threshScore = 0.1;
        atPref = 16; % there is a script in 01_lambda for estimating this
        BP = 50000;
    end
    nmbpHist = zeros(1,NN);
    % BP = 10000; % from seq fasta
    seq=fastaread('sequenceMasked.fasta');

    ts = nt2int(seq.Sequence);
    nSeq = length(ts); % theory + extra things on the left and right
%     sets.theoryGen.atPreference = 16;
    x = gcweighted(ts',4,atPref);

    dataStorage = cell(1,NN);
    lambdaLen = zeros(1,NN);

    for i=1:NN
        sets.nmbp = curSetsNMBP;
        % psf in basepairs, we need to convolve with such Gaussian
        psfSigmaWidth_bps = nmPsf / sets.nmbp;
        % This function converts bpRes to pxRes
        pxSize = nmPx/sets.nmbp;
        numPx = ceil(nSeq/pxSize); % number of pixel

        %% quick and dirty (no need to be precise) theory calculation:
        theory = zeros(1,numPx);
        cutPointsL = round(1:pxSize:nSeq-ceil(pxSize));
        cutPointsR = round(cutPointsL+pxSize-1);
        % kernel values
        y = zeros(nSeq,1);
        y(1:2^15) = images.internal.createGaussianKernel(psfSigmaWidth_bps, 2^15);
        % inverser fourier
        z = circshift(ifft(fft(y).*fft(x)),-2^14);

        lambdaShape = zeros(1,length(cutPointsL));
        for t = 1:length(cutPointsL)
            lambdaShape(t) = mean(z(cutPointsL(t):cutPointsR(t)));
        end
        %   files
        lambdaMask = ones(1,length(lambdaShape));
        sidePx = ceil(BP/(nmPx/ sets.nmbp));% also add some to edges so we don't map things which are quite off
        lambdaMask([1:(sidePx-2) end-sidePx+1+2:end]) = 0;

        %%
        lambdaScaled = lambdaShape/max(lambdaShape);
        lambdaLen(i) =  48502*sets.nmbp/1000;


        % run comparison
        import DBM4.quick_cc;
        [rezMaxM,bestBarStretch,bestLength] = quick_cc(barcodeGen,lambdaScaled, lambdaMask, stretchFactors, bgMean);
        overlap = cellfun(@(x) x.overlap,rezMaxM);
        score = cellfun(@(x) x.maxcoef,rezMaxM);

    %     bestBarStretch = bestBarStretch(bestLength
        % idx = 1;
%         quick_plot({rezMaxM},barcodeGen,theoryStruct,idx,{bestBarStretch},{bestLength})
        goodBarcodes =     (score<threshScore)+(overlap<=sum(lambdaMask))==2;
        [vals,pos] = hist(bestBarStretch(goodBarcodes),stretchFactors);
    %     [vals,pos] =hist(bestBarStretch,stretchFactors);

    % figure,plot(pos,vals);

        [a,b] = max(imgaussfilt(vals,2));

    %     bestStrFac = pos(b);
        bestStrFac = mean(bestBarStretch(goodBarcodes));
        bestStrStd = std(bestBarStretch(goodBarcodes));
        
        curSetsNMBP = curSetsNMBP/bestStrFac;
        nmbpHist(i) = curSetsNMBP;
        
        
        dataStorage{i}.lambdaShape = lambdaShape;
        dataStorage{i}.lambdaMask = lambdaMask;
        dataStorage{i}.rezMaxM = rezMaxM;
        dataStorage{i}.bestBarStretch = bestBarStretch;
        dataStorage{i}.score = score;
        dataStorage{i}.bestStrFac = bestStrFac;
        dataStorage{i}.bestStrStd = bestStrStd;
        dataStorage{i}.lambdaScaled = lambdaScaled;
        dataStorage{i}.lambdaMask = lambdaMask;

        if isnan(bestStrFac)
            warning('No lambda molecules detected.. Try changing some settings')
            nmbpHist = [];
            return
        end

    end

end

