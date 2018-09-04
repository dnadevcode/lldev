function [ contigItems ] = gen_contig_barcodes(sequences, settings )
    % 20/12/16
    % I've edited this to print things out for one particular example,
    % Should simplify and make more accesible and more editable with
    % parameters being passed through the settings file!


    
    %contigLen = settings.contigLen;
   % shiftBp = settings.shiftBp;
    
    %itemLen = floor(length(barcodeBpRes)/contigLen);
    
  %  shiftedBar = circshift(barcodeBpRes,[-shiftBp,0]);

    
    uncReg = settings.uncReg;
    
    import CA.CombAuc.Core.Zeromodel.sequence_barcodes;
    
    [barcodeS,probNums] = sequence_barcodes( sequences,settings,1);
    
    contigItems = cell(1,length(barcodeS));

    length(barcodeS)
    for contigNum = 1:length(barcodeS)
        contigItems{contigNum}.bar = barcodeS{contigNum};
        contigItems{contigNum}.sequence = sequences{probNums(contigNum)};
        % Create the contig barcodes
        %[a] = findstr(sequences{contigNum},plasmid);
        
        contigItems{contigNum}.corPlace = 1;
        %contigItems{contigNum}.corPlace =  (contigNum-1)*contigLen+1;
        
        cutBarc = contigItems{contigNum}.bar(uncReg+1:length( contigItems{contigNum}.bar)-uncReg);
        contigItems{contigNum}.barcode = interp1([1:length(cutBarc)], cutBarc,linspace(1,length(cutBarc),length(cutBarc)/(settings.bpPerNm*settings.camRes )));
        
       % contigItems{contigNum}.corPlacePxStart =  (contigItems{contigNum}.corPlace+uncReg)/(settings.bpPerNm*settings.camRes );
       % contigItems{contigNum}.corPlacePxEnd = contigItems{contigNum}.corPlacePxStart +length(contigItems{contigNum}.barcode)-1;
        contigItems{contigNum}.corPlacePxStart = 0;
        contigItems{contigNum}.corPlacePxEnd = 0;
        contigItems{contigNum}.isRemoved = 1;
        contigItems{contigNum}.isReversed = 0;
        
        contigItems{contigNum}.name = num2str(probNums(contigNum));

        contigItems{contigNum}.PredictedPlacePxStart = contigItems{contigNum}.corPlacePxStart;
        contigItems{contigNum}.PredictedPlacePxEnd = contigItems{contigNum}.PredictedPlacePxStart+length(contigItems{contigNum}.barcode)-1;

    end
    
%     
%     longestSeq = [];
%     %bestStr = {};
%     bestPlaces = [];
%     for seqNr = probNums
%         st=1;
%         a = [1];
%         kkTemp = 1;
%         while(~isempty(a))
%             st = st+1;
%             tt = st*500;
%             a = [];
%             for kk=1:round(length(sequences{seqNr})/tt)-2
%                 a = [a findstr(sequences{seqNr}(kk*tt:(kk+1)*tt),[plasmid plasmid])];
%                 a = [a findstr(seqrcomplement(sequences{seqNr}(kk*tt:(kk+1)*tt)),[plasmid plasmid])];
%                 if ~isempty(a)
%                     kkTemp = kk*tt;
%                     break;
%                 end
%             end
%         end
%         longestSeq = [longestSeq st*500];
%         bestPlaces = [bestPlaces; kkTemp];
%       %  bestStr =  [bestStr sequences{seqNr}((kk-1)*tt:(kk)*tt)];
%     end
% 
%     [indI,b] = sort(longestSeq);
% 
%     selectedSeq = b(indI>5000);
%     
%     contigItems = cell(1,length(selectedSeq));
% 
%     st = 1;
%     for contigNum=selectedSeq
%         cPlace = findstr(sequences{probNums(contigNum)}(bestPlaces(contigNum):bestPlaces(contigNum)+1000),plasmid);
%         if ~isempty(cPlace)
%             contigItems{contigNum}.isReversed = 1;
%         else
%             contigItems{contigNum}.isReversed = 0;
%             cPlace = findstr(seqrcomplement(sequences{probNums(contigNum)}(bestPlaces(contigNum):bestPlaces(contigNum)+1000)),plasmid);
%         end
%         contigItems{contigNum}.corPlacePxStart =  (cPlace-bestPlaces(contigNum)+settings.uncReg)/(settings.bpPerNm*settings.camRes );
%         contigItems{contigNum}.corPlacePxEnd = contigItems{contigNum}.corPlacePxStart +length(contigItems{contigNum}.barcode)-1;
%         st = st+1;
%     end


end