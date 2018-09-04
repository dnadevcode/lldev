function [ contigItems ] = gen_fake(barcodeBpRes, settings)
    % 20/12/16
    % I've edited this to print things out for one particular example,
    % Should simplify and make more accesible and more editable with
    % parameters being passed through the settings file!

    contigLen = settings.contigLen;
    uncReg = settings.uncReg;

    itemLen = settings.lengthBarcode;

    % contig every pixel
    contigShift = round(settings.kbpPerPixel);
    
    contigItems = cell(1,itemLen);

    for contigNum = 1:itemLen
        % Create the contig barcodes
        contigItems{contigNum}.bar = barcodeBpRes(1:contigLen);
        contigItems{contigNum}.corPlace =  (contigNum-1)*contigShift+1;

        cutBarc = contigItems{contigNum}.bar(uncReg+1:length(contigItems{contigNum}.bar)-uncReg);
        contigItems{contigNum}.barcode = interp1([1:length(cutBarc)], cutBarc,linspace(1,length(cutBarc),length(cutBarc)/(settings.kbpPerPixel )));
        
        contigItems{contigNum}.corPlacePxStart =  (contigItems{contigNum}.corPlace+uncReg)/(settings.kbpPerPixel)+1; % does it need +1 here?
        contigItems{contigNum}.corPlacePxEnd = contigItems{contigNum}.corPlacePxStart +length(contigItems{contigNum}.barcode)+1;
        
        contigItems{contigNum}.isRemoved = 1;
        contigItems{contigNum}.isReversed = 0;

        contigItems{contigNum}.name = num2str(contigNum);

        contigItems{contigNum}.PredictedPlacePxStart = contigItems{contigNum}.corPlacePxStart;
        contigItems{contigNum}.PredictedPlacePxEnd = contigItems{contigNum}.PredictedPlacePxStart+length(contigItems{contigNum}.barcode);
        
        barcodeBpRes = circshift(barcodeBpRes,[-contigShift,0]);
    end

end