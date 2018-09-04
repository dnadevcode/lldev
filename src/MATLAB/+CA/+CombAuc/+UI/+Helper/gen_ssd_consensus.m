function [ consensusNew ] = gen_ssd_consensus( molStruct, sets )
    tic

      for xInd = 1:length(molStruct)
     %for xInd = 6
        % number of barcodes
        numBarcodes = length(molStruct{xInd}.rawBarcodes )-1;

        rawBar = zeros(numBarcodes,length(molStruct{xInd}.rawBarcodes{1}));
        rawBit =  zeros(numBarcodes,length(molStruct{xInd}.rawBarcodes{1}));
        for j=1:numBarcodes
         %   rawBar(j,:) =molStruct{i}.rawBarcodes{j} -molStruct{i}.barcodeGen{j}.bgMeanApprox;
            if isequal(sets.barcodeConsensusSettings.barcodeNormalization,'zscore')
                rawBar(j,:) =zscore(molStruct{xInd}.rawBarcodes{j} -molStruct{xInd}.barcodeGen{j}.bgMeanApprox);
            else
                rawBar(j,:) =molStruct{xInd}.rawBarcodes{j} -molStruct{xInd}.barcodeGen{j}.bgMeanApprox;
            end
            rawBit(j,:) = molStruct{xInd}.rawBitmasks{j};
            rawBar(j,logical(~rawBit(j,:))) = 0;
        end

        % this computes all the xcorrs for the individual barcodes to the
        % corresponding barcodes
        % stores every value in the xcorrs structure (for the future, just
        % store the max and the position of the max)


        xcorrs = cell(numBarcodes-1,numBarcodes-1);
       % xcorrsSSD = cell(numBarcodes-1,numBarcodes);

        for barcodeIdxA = 1:numBarcodes-1
            barcodeA = rawBar(barcodeIdxA,:);
            bitmaskA = rawBit(barcodeIdxA,:);

            for barcodeIdxB = barcodeIdxA+1:numBarcodes
                barcodeB = rawBar(barcodeIdxB,:);
                bitmaskB = rawBit(barcodeIdxB,:);

                import CBT.Hca.Core.Comparison.SSD_fft;
                import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
                xcorrs{barcodeIdxA,barcodeIdxB-1} = get_no_crop_lin_circ_xcorrs(barcodeA,barcodeB,bitmaskA,bitmaskB);
               % [xcorrsSSD{barcodeIdxA,barcodeIdxB},indices] = SSD_fft(barcodeA,barcodeB,bitmaskA,bitmaskB,round(length(barcodeA)/2));
            end     
        end


        maxcoef = zeros(numBarcodes-1,numBarcodes-1);
        or = zeros(numBarcodes-1,numBarcodes-1);
        pos = zeros(numBarcodes-1,numBarcodes-1);
         for barcodeIdxA = 1:numBarcodes-1
            for barcodeIdxB = barcodeIdxA+1:numBarcodes
                % best position stuff!
                [f,s] = max(xcorrs{barcodeIdxA,barcodeIdxB-1});          
                [ b, ix ] = sort( f(:), 'descend' );
                indx = b(1:1)' ;
                maxcoef(barcodeIdxA,barcodeIdxB-1) = indx;
           %  resultStruc.pos = [resultStruc.pos; ix(1:3)'];
                or(barcodeIdxA,barcodeIdxB-1) =s(ix(1:1)');

                if s(ix(1:1)') == 1
                    pos(barcodeIdxA,barcodeIdxB-1) = ix(1:1)';
                else
                    pos(barcodeIdxA,barcodeIdxB-1) = ix(1:1)'-length(barcodeA);
                end 
            end
         end

         rawBar2 = rawBar;
         rawBit2 = rawBit;
         barToAverage = zeros(numBarcodes,numBarcodes);
         barInd =1:numBarcodes;
        % removedB = [];
         for bb=1:numBarcodes-1
             % find which barcodes should be merged
             [M,I] = max(maxcoef(:));
             if M < sets.barcodeConsensusSettings.barcodeClusterLimit
                 break;
             end
             [I_row, I_col] = ind2sub(size(maxcoef),I);
             %removedB = [removedB I_col];
             % note which barcodes are merged !
             if barToAverage(I_row,barInd(I_row))==0
                barToAverage(I_row,barInd(I_row))= 1;
             end
             if barToAverage(I_col+1,barInd(I_col+1)) == 0
                barToAverage(I_col+1,barInd(I_col+1)) = 1;
             end
              % make sure that all the barcodes that need to be averaged are averaged..
             barToAverage(I_row,:) = max(barToAverage(I_row,:),barToAverage(I_col+1,:));


             % after merging, there is one less dimension in the maxcoef, and
             % we have to recompute the coefficients for the new averaged
             % barcode..

%% UNCOMMENT FOR TESTING
%              barExtra = rawBar2(I_col+1,:);
%              bitExtra = rawBit2(I_col+1,:);
%              barExtra1 = rawBar2(I_row,:);
%              bitExtra1 = rawBit2(I_row,:);
%          

             rawBar2(I_col+1,:) = [];
             rawBit2(I_col+1,:) = [];

             % need to circshift the second barcode the right amount first
             % if a barcode is being removed, then it is circ-shifted to the
             % barcode that it is being added to, then these two have the same
             % alignment. What to do when there are two different clusters that
             % we want to add together?

             % 

             % case when more than one barcode was added to the average before
             if sum(barToAverage(I_col+1,:)) > 1
                % barcodes are always oriented to the one which is first in the
                % list, so always easy to orientate according to that one.
                [a] = find(barToAverage(I_col+1,:));
                for i=1:length(a)
                     if or(I_row, I_col) == 2
                         rawBar(a(i),:) = fliplr(rawBar(a(i),:));
                         rawBit(a(i),:) = fliplr(rawBit(a(i),:));

    %                      rawBar(a(i),:) = circshift(rawBar(a(i),:),[0,-pos(I_row, I_col)]);
    %                      rawBit(a(i),:) = circshift(rawBit(a(i),:),[0,-pos(I_row, I_col)])
                        
 %rawBar(a(i),:) = circshift(rawBar(a(i),:),[0,pos( find(barInd==I_row), find(barInd == I_col))]);
  %                       rawBit(a(i),:) = circshift(rawBit(a(i),:),[0,pos(find(barInd==I_row), find(barInd == I_col))]);

                        rawBar(a(i),:) = circshift(rawBar(a(i),:),[0,pos( I_row, I_col)-1]);
                        rawBit(a(i),:) = circshift(rawBit(a(i),:),[0,pos(I_row,  I_col)-1]);
                     else
                         rawBar(a(i),:) = circshift(rawBar(a(i),:),[0,-pos(I_row, I_col)+1]);
                         rawBit(a(i),:) = circshift(rawBit(a(i),:),[0,-pos(I_row, I_col)+1]);
                     end
                end
%%% UNCOMMENT IF DOING TESTING
%                 % only for testin, remove later...
%                 if or(I_row, I_col) == 2
%                      barExtra = fliplr(barExtra);
%                      bitExtra = fliplr(bitExtra);
% 
% %                      rawBar(a(i),:) = circshift(rawBar(a(i),:),[0,-pos(I_row, I_col)]);
% %                      rawBit(a(i),:) = circshift(rawBit(a(i),:),[0,-pos(I_row, I_col)])
% 
% %rawBar(a(i),:) = circshift(rawBar(a(i),:),[0,pos( find(barInd==I_row), find(barInd == I_col))]);
% %                       rawBit(a(i),:) = circshift(rawBit(a(i),:),[0,pos(find(barInd==I_row), find(barInd == I_col))]);
% 
%                     barExtra = circshift(barExtra,[0,pos( I_row, I_col)-1]);
%                     bitExtra = circshift(bitExtra,[0,pos(I_row,  I_col)-1]);
%                  else
%                      barExtra= circshift(barExtra,[0,-pos(I_row, I_col)+1]);
%                      bitExtra = circshift(bitExtra,[0,-pos(I_row, I_col)+1]);
%                  end

             else
                 [a] = find(barToAverage(I_col+1,:));
                 if or(I_row,  I_col) == 2
                     rawBar(a,:) = fliplr(rawBar(a,:));
                     rawBit(a,:) = fliplr(rawBit(a,:));

                     rawBar(a,:) = circshift(rawBar(a,:),[0,pos( I_row, I_col)-1]);
                     rawBit(a,:) = circshift(rawBit(a,:),[0,pos(I_row, I_col)-1]);
                 else
                     rawBar(a,:) = circshift(rawBar(a,:),[0,-pos( I_row, I_col)+1]);    % this is ok! (tested)
                     rawBit(a,:) = circshift(rawBit(a,:),[0,-pos(I_row, I_col)+1]);
                 end
%                 figure,plot(zscore(rawBar(I_col+1,:)))
%                     hold on
%                 plot(zscore(rawBar(I_row,:)))
%         
        %          figure,plot(rawBar(I_col+1,:))
        %             hold on
        %         plot(rawBar(I_row,:))
             end
             % need to remove this row since it won't appear again.
             % If we need to show!
          %   figure,plot(rawBar(logical(barToAverage(I_row,:)),:)')
            
%%% THE TEST PHASE IS TO CHECK IF THE BARCODES ARE ALIGNED CORRECTLY, WE DO
%%% NOT NEED THI IN THE FINAL VERSION... BUT WHENEVER WE CHANGE SOMETHING
%%% THIS IS USEFUL TO LOOK AT. ALSO NOTE THAT SINGLE BARCODE-TO-BARCODE
%%% MIGHT NOT BE ALIGNED TO THE SAME PLACE HERE. MAYBE THIS COULD BE
%%% WRITTEN UP IN A DIFFERENT METHOD?

%              % test
%             find(logical(barToAverage(I_row,:)))
%             find(logical(barToAverage(I_col+1,:)))
% % 
%              barcod = rawBar(logical(barToAverage(I_row,:)),:);
%              bitmas =  rawBit(logical(barToAverage(I_row,:)),:);
%              barcodA = barcod(1,:);
%              bitmasA = bitmas(1,:);
% % 
% %              for i=2:size(barcod,1)
% %                 barcodB = barcod(i,:);
% %                 bitmasB = bitmas(i,:);
% %                  import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
% %                 xxx = get_no_crop_lin_circ_xcorrs(barcodA,barcodB,bitmasA,bitmasB);
% %                 [A,B] =max(xxx(:))
% % 
% %              end
% 
%              if sum(barToAverage(I_col+1,:)) > 1
%                  import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
%                  xxx = get_no_crop_lin_circ_xcorrs(barcodA,barExtra,bitmasA,bitExtra);
%                  display('averaging more than one');
%                  [A,B] =max(xxx(:))
%              end
% 
%              barcod = rawBar(logical(barToAverage(I_col+1,:)),:);
%              bitmas =  rawBit(logical(barToAverage(I_col+1,:)),:);
%              for i=1:size(barcod,1)
%                 barcodB = barcod(i,:);
%                 bitmasB = bitmas(i,:);
% %                  import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
% %                 xxx = get_no_crop_lin_circ_xcorrs(barcodA,barcodB,bitmasA,bitmasB);
% %                 [A,B] =max(xxx(:))
% 
%                 if sum(barToAverage(I_row,:)) > 1
%                     import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
%                      xxx = get_no_crop_lin_circ_xcorrs(barExtra1,barcodB,bitExtra1,bitmasB);
%                      display('first is more than one');
%                      [A,B] =max(xxx(:))
%                 end
% 
%              end
%             
%             if length( find(logical(barToAverage(I_row,:))))>1&& length( find(logical(barToAverage(I_col+1,:))))>1
%                     import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
%                      xxx = get_no_crop_lin_circ_xcorrs(barExtra1,barExtra,bitExtra1,bitExtra);
%                      display('both longer than one');
%                      [A,B] =max(xxx(:))
%             end
% 
%              %

             barToAverage(I_col+1,:) = [];
             barInd(I_col+1) = [];
             rawBar2(I_row,:) = nanmean(rawBar(logical(barToAverage(I_row,:)),:));
             rawBit2(I_row,:) = max(rawBit(logical(barToAverage(I_row,:)),:));
             
             if I_col+1 < size(maxcoef,1)
                maxcoef(I_col+1,:) = [];
                pos(I_col+1,:) = [];
                or(I_col+1,:) = [];
                xcorrs(I_col+1,:) = [];
            end


             maxcoef(:,I_col) = [];
             pos(:,I_col) = [];
             or(:,I_col) = [];
             xcorrs(:,I_col) = [];


            for barcodeIdxA = 1:I_row-1
                barcodeA = rawBar2(barcodeIdxA,:);
                bitmaskA = rawBit2(barcodeIdxA,:);
                barcodeB = rawBar2(I_row,:);
                bitmaskB = rawBit2(I_row,:);
               % import CBT.Hca.Core.Comparison.SSD_fft;
                import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
                xcorrs{barcodeIdxA,I_row-1} = get_no_crop_lin_circ_xcorrs(barcodeA,barcodeB,bitmaskA,bitmaskB);
               % [xcorrsSSD{barcodeIdxA,barcodeIdxB},indices] = SSD_fft(barcodeA,barcodeB,bitmaskA,bitmaskB,round(length(barcodeA)/2));
            end

            for barcodeIdxA = I_row+1:numBarcodes-1-bb
                barcodeA = rawBar2(I_row,:);
                bitmaskA = rawBit2(I_row,:);
                barcodeB = rawBar2(barcodeIdxA,:);
                bitmaskB = rawBit2(barcodeIdxA,:);
               % import CBT.Hca.Core.Comparison.SSD_fft;
                import SignalRegistration.XcorrAlign.get_no_crop_lin_circ_xcorrs;
                xcorrs{I_row,barcodeIdxA-1} = get_no_crop_lin_circ_xcorrs(barcodeA,barcodeB,bitmaskA,bitmaskB);
               % [xcorrsSSD{barcodeIdxA,barcodeIdxB},indices] = SSD_fft(barcodeA,barcodeB,bitmaskA,bitmaskB,round(length(barcodeA)/2));
            end
            maxcoef = zeros(numBarcodes-1-bb,numBarcodes-1-bb);
            or = zeros(numBarcodes-1-bb,numBarcodes-1-bb);
            pos = zeros(numBarcodes-1-bb,numBarcodes-1-bb);
             for barcodeIdxA = 1:numBarcodes-1-bb
                for barcodeIdxB = barcodeIdxA+1:1:numBarcodes-bb
                    % best position stuff!
                    [f,s] = max(xcorrs{barcodeIdxA,barcodeIdxB-1});          
                    [ b, ix ] = sort( f(:), 'descend' );
                    indx = b(1:1)' ;
                    maxcoef(barcodeIdxA,barcodeIdxB-1) = indx;
                    or(barcodeIdxA,barcodeIdxB-1) =s(ix(1:1)');

                    if s(ix(1:1)') == 1
                        pos(barcodeIdxA,barcodeIdxB-1) = ix(1:1)';
                    else
                        pos(barcodeIdxA,barcodeIdxB-1) = ix(1:1)'-length(barcodeA);
                    end 
                end
             end    
         end
         
         [numB,mostB] = max(sum(barToAverage'));
         if size(mostB,2)>1
             mostB = mostB(1);
             numB = numB(1);
         end
         
         consensusNew{xInd}.barcode = rawBar2(mostB,:);
         consensusNew{xInd}.bitmask = rawBit2(mostB,:);
         consensusNew{xInd}.numBarcodes = numB;
    end

        timePassed = toc;
        display(strcat(['All consensuses generated in ' num2str(timePassed) ' seconds']));

    
end

