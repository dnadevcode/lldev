function [ contigItems ] = gen_fake_barcodes(barcodeBpRes, settings )
    % 20/12/16
    % I've edited this to print things out for one particular example,
    % Should simplify and make more accesible and more editable with
    % parameters being passed through the settings file!

    
    contigLen = settings.contigLen;
    shiftBp = settings.shiftBp;
    
    itemLen = floor(length(barcodeBpRes)/contigLen);
    
    shiftedBar = circshift(barcodeBpRes,[-shiftBp,0]);

    contigItems = cell(1,itemLen);
    
    uncReg = settings.uncReg;
    
    for contigNum = 1:itemLen
        % Create the contig barcodes
        contigItems{contigNum}.bar = shiftedBar((contigNum-1)*contigLen+1:contigNum*contigLen);
        contigItems{contigNum}.corPlace =  (contigNum-1)*contigLen+1;
        
        cutBarc = contigItems{contigNum}.bar(uncReg+1:length( contigItems{contigNum}.bar)-uncReg);
        contigItems{contigNum}.barcode = interp1([1:length(cutBarc)], cutBarc,linspace(1,length(cutBarc),length(cutBarc)/(settings.bpPerNm*settings.camRes )));
        contigItems{contigNum}.corPlacePxStart =  (contigItems{contigNum}.corPlace)/(settings.bpPerNm*settings.camRes )+1; % does it need +1 here?
        contigItems{contigNum}.corPlacePxEnd = contigItems{contigNum}.corPlacePxStart +uncReg/(settings.bpPerNm*settings.camRes )+length(contigItems{contigNum}.barcode)+1;

        contigItems{contigNum}.isRemoved = 1;
        contigItems{contigNum}.isReversed = 0;
        
        contigItems{contigNum}.BelongsToSeq = 1;
        contigItems{contigNum}.isTooShort = 0;
        contigItems{contigNum}.placeInd = contigNum;

        
        contigItems{contigNum}.name = num2str(contigNum);

        contigItems{contigNum}.PredictedPlacePxStart = contigItems{contigNum}.corPlacePxStart;
        contigItems{contigNum}.PredictedPlacePxEnd = contigItems{contigNum}.PredictedPlacePxStart+length(contigItems{contigNum}.barcode);

    end


end