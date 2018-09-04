function [ caSessionStruct ] = gen_barcodes_for_contigs(caSessionStruct)
    % 05/07/17

    import CA.CombAuc.Core.Zeromodel.compute_sequence_barcodes; 
    [caSessionStruct.theoryCurveUnscaled_pxRes,caSessionStruct.bitmasks] = compute_sequence_barcodes( caSessionStruct.contigData{1},caSessionStruct.barcodeGenSettings ,1);
    
%     contigItems = cell(1,length(barcodeS));
% 
%     length(barcodeS)
%     for contigNum = 1:length(barcodeS)
%         contigItems{contigNum}.bar = barcodeS{contigNum};
%         contigItems{contigNum}.sequence = sequences{probNums(contigNum)};
%         % Create the contig barcodes
%         %[a] = findstr(sequences{contigNum},plasmid);
%         
%         contigItems{contigNum}.corPlace = 1;
%         %contigItems{contigNum}.corPlace =  (contigNum-1)*contigLen+1;
%         
%         cutBarc = contigItems{contigNum}.bar(uncReg+1:length( contigItems{contigNum}.bar)-uncReg);
%         contigItems{contigNum}.barcode = interp1([1:length(cutBarc)], cutBarc,linspace(1,length(cutBarc),length(cutBarc)/(barcodeGenSettings.bpPerNm*barcodeGenSettings.camRes )));
%         
%        % contigItems{contigNum}.corPlacePxStart =  (contigItems{contigNum}.corPlace+uncReg)/(settings.bpPerNm*settings.camRes );
%        % contigItems{contigNum}.corPlacePxEnd = contigItems{contigNum}.corPlacePxStart +length(contigItems{contigNum}.barcode)-1;
%         contigItems{contigNum}.corPlacePxStart = 0;
%         contigItems{contigNum}.corPlacePxEnd = 0;
%         contigItems{contigNum}.isRemoved = 1;
%         contigItems{contigNum}.isReversed = 0;
%         
%         contigItems{contigNum}.name = num2str(probNums(contigNum));
% 
%         contigItems{contigNum}.PredictedPlacePxStart = contigItems{contigNum}.corPlacePxStart;
%         contigItems{contigNum}.PredictedPlacePxEnd = contigItems{contigNum}.PredictedPlacePxStart+length(contigItems{contigNum}.barcode)-1;
% 
%     end
%     caSessionStruct.contigItems = contigItems;

end