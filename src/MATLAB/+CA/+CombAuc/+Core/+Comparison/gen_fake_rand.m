function [ contigItems ] = gen_fake_rand(mol2, sets)
    % gen_fake_rand
    
    %cutPlaces = randi(100000,100,1);
    
    bar = mol2.barcodeBpRes;

    % first define a random distribution with pre-defined mean parameter
    pd=makedist('Exponential','mu',sets.meanContigLength);
    
    % truncate the distribution, since we can not have sequences longer
    % than the length of the plasmid
    t=truncate(pd,0,length(bar));
    
    % now find a set of places at which to cut
    cutPlaces = round(t.random(1000,1));
    
    % compute the cummulative sum
    indCur = cumsum(cutPlaces);
    
    %%%
  %  contigItems = {};
   % sequences = {};
  
    %contigLen = sets.contigLen;
    uncReg = sets.untrustedBp;

   % itemLen = sets.lengthBarcode;

    % contig every pixel
    contigShift = sets.barcodeConsensusSettings.prestretchPixelWidth_nm/sets.meanBpExt_nm;
    strr = sets.meanBpExt_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;

    %contigShift = round(sets.kbpPerPixel);
    
    nr = find(indCur  > length(bar),1,'first');
    contigItems = cell(1,nr-1);

    for contigNum = 1:length(cutPlaces)
         if (indCur(contigNum+1) > length(bar))
             if indCur(contigNum) > length(bar)
                 break;
             end
             contigItems{contigNum}.bar = [bar(indCur(contigNum):end);bar(1:indCur(1))];
         else
             contigItems{contigNum}.bar = bar(indCur(contigNum):indCur(contigNum)+cutPlaces(contigNum+1));
         end

        contigItems{contigNum}.corPlace = indCur(contigNum)+1; % + uncReg
        lenBar = length(contigItems{contigNum}.bar);
        contigItems{contigNum}.contigBitmask = zeros(1,lenBar);

        if lenBar > 2*uncReg
            contigItems{contigNum}.contigBitmask(uncReg:end-uncReg+1) = ones(1,length(contigItems{contigNum}.contigBitmask(uncReg:end-uncReg+1)));
            import CBT.Core.convert_bpRes_to_pxRes;
            contigItems{contigNum}.barcode = convert_bpRes_to_pxRes(contigItems{contigNum}.bar, strr);
            v = linspace(1, length(contigItems{contigNum}.contigBitmask),  length( contigItems{contigNum}.barcode ));
            contigItems{contigNum}.bit = contigItems{contigNum}.contigBitmask(round(v));
        else
            v = linspace(1, length(contigItems{contigNum}.contigBitmask),  lenBar*strr);
            contigItems{contigNum}.bit = contigItems{contigNum}.contigBitmask(round(v));
            contigItems{contigNum}.barcode = zeros(1,length( contigItems{contigNum}.bit ));
        end

        
        contigItems{contigNum}.corPlacePxStart =  (contigItems{contigNum}.corPlace)/(contigShift)+1; % does it need +1 here?
       % contigItems{contigNum}.corPlacePxEnd = contigItems{contigNum}.corPlacePxStart +length(contigItems{contigNum}.barcode);

        contigItems{contigNum}.isRemoved = 1;
        contigItems{contigNum}.isReversed = 0;
        contigItems{contigNum}.isChromosomal = 0;

        contigItems{contigNum}.name = num2str(contigNum);

        contigItems{contigNum}.PredictedPlacePxStart = contigItems{contigNum}.corPlacePxStart;
        %contigItems{contigNum}.PredictedPlacePxEnd = contigItems{contigNum}.corPlacePxEnd;
    end
    
      lengthInBP = cellfun(@(x) length(x.bar),contigItems);
    [a,b] = sort(lengthInBP,'descend');
      for contigNum = 1:length(contigItems)
      	contigItems{contigNum}.name = num2str(find(contigNum==b));
      end
    if sets.addChromosomalContigs == 1
        lCon = length(contigItems);

        bar = mol2.theoryBarcodeBpRes;

        % first define a random distribution with pre-defined mean parameter
        pd=makedist('Exponential','mu',sets.meanContigLength);

        % truncate the distribution, since we can not have sequences longer
        % than the length of the plasmid
        t=truncate(pd,0,length( mol2.barcodeBpRes));

        % now find a set of places at which to cut
        cutPlaces = round(t.random(1000,1));
    
        % compute the cummulative sum
        indCur = cumsum(cutPlaces);
    
        %%%
      %  contigItems = {};
       % sequences = {};

        %contigLen = sets.contigLen;
        uncReg = sets.untrustedBp;

       % itemLen = sets.lengthBarcode;

        % contig every pixel
        contigShift = sets.barcodeConsensusSettings.prestretchPixelWidth_nm/sets.meanBpExt_nm;
        strr = sets.meanBpExt_nm/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;

    %contigShift = round(sets.kbpPerPixel);
    
        nr = find(indCur  > length(bar),1,'first');
        
      
       for contigNum = 1:length(cutPlaces)
             if (indCur(contigNum+1) > length(bar))
                 if indCur(contigNum) > length(bar)
                     break;
                 end
                 contigItems{lCon+contigNum}.bar = [bar(indCur(contigNum):end);bar(1:indCur(1))];
             else
                 contigItems{lCon+contigNum}.bar = bar(indCur(contigNum):indCur(contigNum)+cutPlaces(contigNum+1));
             end

            contigItems{lCon+contigNum}.corPlace = indCur(contigNum)+1; % + uncReg
            lenBar = length(contigItems{lCon+contigNum}.bar);
            contigItems{lCon+contigNum}.contigBitmask = zeros(1,lenBar);

            if lenBar > 2*uncReg
                contigItems{lCon+contigNum}.contigBitmask(uncReg:end-uncReg+1) = ones(1,length(contigItems{lCon+contigNum}.contigBitmask(uncReg:end-uncReg+1)));
                import CBT.Core.convert_bpRes_to_pxRes;
                contigItems{lCon+contigNum}.barcode = convert_bpRes_to_pxRes(contigItems{lCon+contigNum}.bar, strr);
                v = linspace(1, length(contigItems{lCon+contigNum}.contigBitmask),  length( contigItems{lCon+contigNum}.barcode ));
                contigItems{lCon+contigNum}.bit = contigItems{lCon+contigNum}.contigBitmask(round(v));
            else
                v = linspace(1, length(contigItems{lCon+contigNum}.contigBitmask),  lenBar*strr);
                contigItems{lCon+contigNum}.bit = contigItems{lCon+contigNum}.contigBitmask(round(v));
                contigItems{lCon+contigNum}.barcode = zeros(1,length( contigItems{lCon+contigNum}.bit ));
            end


            contigItems{lCon+contigNum}.corPlacePxStart =  (contigItems{lCon+contigNum}.corPlace)/(contigShift)+1; % does it need +1 here?
            % contigItems{contigNum}.corPlacePxEnd = contigItems{contigNum}.corPlacePxStart +length(contigItems{contigNum}.barcode);

            contigItems{lCon+contigNum}.isRemoved = 1;
            contigItems{lCon+contigNum}.isReversed = 0;
            contigItems{lCon+contigNum}.isChromosomal = 1;

            contigItems{lCon+contigNum}.name = num2str(lCon+contigNum);

            contigItems{lCon+contigNum}.PredictedPlacePxStart = contigItems{lCon+contigNum}.corPlacePxStart;
            %contigItems{contigNum}.PredictedPlacePxEnd = contigItems{contigNum}.corPlacePxEnd;
       end
    
    end


end