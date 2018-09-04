function [ ] = plot_contigs4(refCurve, contigItems,titleName, ccValueMatrix, pValueMatrix,colors )
% comparison graph plot
% 13/02/17
% PLOTS CORRECT PLACE

   % h = figure; 
  %  subplot(1,4,[1,2,3]);
    title(titleName,'Interpreter','latex')
    hold on;
    
    ylabel('Rescaled intensity', 'Interpreter','latex')
    ax = gca;
    ticks = 1:50:length(refCurve);
    ticksx = floor(ticks*592/1000);
    ax.XTick = [ticks];
    ax.XTickLabel = [ticksx];
    xlabel('Position (kbp)','Interpreter','latex')
    
    plot(refCurve, 'black');
    hold on;
    legendInfo = {};
    legendInfo{1} = ['Consensus'];

    if ~isempty(pValueMatrix)
        nInd = 1;
        %h1 = cell(1,5);
       % h1{1} = plot(refCurve, 'black'); % or whatever is appropriate
        for contigNum=1:size(contigItems,2) % does not include flip option
            if	contigItems{contigNum}.isRemoved == 0 && contigItems{contigNum}.isTooShort == 0 ;
                if contigItems{contigNum}.isReversed == 0
                    pVal = pValueMatrix(contigNum,round(contigItems{contigNum}.PredictedPlacePxStart)+length(refCurve));
                else
                    pVal = pValueMatrix(contigNum,round(contigItems{contigNum}.PredictedPlacePxStart));
                end
                %pVal
                %contigNum
               % contigItems{contigNum}.PredictedPlacePxStart

                bit = 0;

                startBarcode = round(contigItems{contigNum}.PredictedPlacePxStart)+bit-0;
                stopBarcode = round(contigItems{contigNum}.PredictedPlacePxEnd);
                contigNum


                barc = contigItems{contigNum}.barcode;
                barc = zscore(barc(1+bit:end-bit));

                % nnz(revBi(optimalBid(barcIndex,1),optimalBid(barcIndex,2)))
                if contigItems{contigNum}.isReversed == 0
                   barc = fliplr(barc); 
                end


                if stopBarcode < startBarcode
                    pixelList = [startBarcode:length(refCurve)];
                    %size(xx)
                    %size(barc)
                    %h1 = plot(pixelList,barc(1:length(pixelList)), 'color', colors(contigNum,:),'linewidth',2);
                    xx2 = [1:stopBarcode];


                    h = plot([ pixelList NaN xx2],[barc(1:length(pixelList)) NaN  barc(length(pixelList)+1:length(barc)) ], 'color', colors(contigNum,:),'linewidth',2);   

                 else       
                    pixelList = startBarcode:stopBarcode;
                    %pixelList
                   % contigNum
                  %  startBarcode
                    localMean = mean(refCurve(startBarcode:stopBarcode));
                    localStd = std(refCurve(startBarcode:stopBarcode));

                    barc = barc*localStd+localMean;
                      %  size(xx)
                       % size(barc)
                   % length(pixelList)
                   % length(barc)
                     plot(pixelList,barc,'linewidth',2,'color', colors(contigNum,:));
                end
                legendInfo{nInd+1} = [ '$\hat C_'  contigItems{contigNum}.name '=$' num2str(max(ccValueMatrix(contigNum,:)),'%.2f ') ', p-val=' num2str(pVal,'%.1e ')]; % or whatever is appropriate
                nInd = nInd+1;
            end
            %size(legendInfo)
            %legend([h1{1} h1{2} ] ,legendInfo)
            legend(legendInfo,'Interpreter','latex','location', 's');
% 
    %
        end    
        
    end
    st = 1;
    for contigNum=1:size(contigItems,2) % does not include flip option
    	if contigItems{contigNum}.BelongsToSeq == 1
             startBarcode = round(contigItems{contigNum}.corPlacePxStart);
             stopBarcode = round(contigItems{contigNum}.corPlacePxEnd);
             if stopBarcode < startBarcode
                 pixelList = [startBarcode:length(refCurve)]
                 xx2= [1:stopBarcode]; 
                 plot([ pixelList NaN xx2],[ones(size(pixelList))*max(refCurve) NaN  ones(size(xx2))*max(refCurve) ], 'color', colors(contigNum,:),'linewidth',2);   
               %  text(pixelList(round(end/4)),max(refCurve)+0.2, strcat([ num2str(contigItems{contigNum}.name)]),'Interpreter','latex')

             else
                 pixelList = startBarcode:stopBarcode;
                 plot(pixelList,[ones(size(pixelList))*max(refCurve)+0.1*contigItems{contigNum}.placeInd],'linewidth',2,'color', colors(contigNum,:));
                 text(pixelList(round(end/4)),max(refCurve)+0.1*contigItems{contigNum}.placeInd+0.2, strcat([ num2str(contigItems{contigNum}.name)]),'Interpreter','latex')
             end
             st = st+1;
        end
    end

%         subplot(1,4,4);
%         clear legendInfo;
% 
%         hold on;
%         numRem = 0;
%         for contigNum=1:size(contigItems,2) % does not include flip option
%             if	contigItems{contigNum}.isRemoved == 1 && contigItems{contigNum}.isTooShort~=1 && numRem < 5;
%                 startBarcode = round(contigItems{contigNum}.corPlacePxStart);
%                 stopBarcode = round(contigItems{contigNum}.corPlacePxEnd);
%                 plot(zscore(contigItems{contigNum}.barcode)/2+numRem,'linewidth',2,'color', colors(contigNum,:));
% 
%                 pVal = min(pValueMatrix(contigNum,:));
% 
% 
%                 %legendInfo{nInd+1} = ['contig' contigItems{contigNum}.name ', p-val=' num2str(pVal,'%.1e ')]; % or whatever is appropriate
%                 legendInfo{numRem+1} = ['contig' ' ' contigItems{contigNum}.name ',' ' ' 'cc=' num2str(max(ccValueMatrix(contigNum,:)),'%.2f ') ', p-val=' num2str(pVal,'%.2f ')]; % or whatever is appropriate
%                 numRem = numRem+1;
% 
%             end
%         end
%         
%         
%         %  legendInfo{contigNum+1} = ['contig ' contigItems{contigNum}.name]; % or whatever is appropriate
%         %     legend(legendInfo,'location', 'sw')
% %        if legendInfo
%  %           legend(legendInfo,'location', 'sw','FontSize',8)
%   %      end
%         title({'Examples of'; 'removed contigs'})
%         

%     

%     
%     
%     bit = 0;
%     
%     h = figure;
%     
%     ylabel('Rescaled intensity')
%     ax = gca;
%     ticks = 1:50:length(refCurve);
%     ticksx = floor(ticks*592/1000);
%     ax.XTick = [ticks];
%     ax.XTickLabel = [ticksx];
%     x0label('Position (kbp)')
%     
%     
%     subplot(1,4,[1,2,3]);
%     title(titleName)
%     hold on;
%     
%     %refCurve2 = fliplr(refCurve);
%     plot(refCurve, 'black');
%     legendInfo = {};
%     legendInfo{1} = ['Consensus'];
% 
% 
%     nInd = 1;
%     %h1 = cell(1,5);
%    % h1{1} = plot(refCurve, 'black'); % or whatever is appropriate
%     for contigNum=1:size(contigItems,2) % does not include flip option
%         if	contigItems{contigNum}.isRemoved == 0;
%             if contigItems{contigNum}.isReversed == 0
%                 pVal = pValueMatrix(contigNum,round(contigItems{contigNum}.PredictedPlacePxStart)+length(refCurve));
%             else
%                 pVal = pValueMatrix(contigNum,round(contigItems{contigNum}.PredictedPlacePxStart));
%             end
%             %pVal
%             %contigNum
%            % contigItems{contigNum}.PredictedPlacePxStart
%             legendInfo{nInd+1} = ['contig' contigItems{contigNum}.name ', cc=' num2str(max(ccValueMatrix(contigNum,:)),'%.2f ') ', p-val=' num2str(pVal,'%.1e ')]; % or whatever is appropriate
%             nInd = nInd+1;
%             startBarcode = round(contigItems{contigNum}.PredictedPlacePxStart)+bit-0;
%             stopBarcode = round(contigItems{contigNum}.PredictedPlacePxEnd);
%             barc = contigItems{contigNum}.barcode;
%             barc = zscore(barc(1+bit:end-bit));
% 
%             % nnz(revBi(optimalBid(barcIndex,1),optimalBid(barcIndex,2)))
%             if contigItems{contigNum}.isReversed == 0
%                barc = fliplr(barc); 
%             end
% 
%             
%             if stopBarcode < startBarcode
%                 pixelList = [startBarcode:length(refCurve)];
%                 %size(xx)
%                 %size(barc)
%                 %h1 = plot(pixelList,barc(1:length(pixelList)), 'color', colors(contigNum,:),'linewidth',2);
%                 xx2 = [1:stopBarcode];
%               
%                 
%                 h = plot([ pixelList NaN xx2],[barc(1:length(pixelList)) NaN  barc(length(pixelList)+1:length(barc)) ], 'color', colors(contigNum,:),'linewidth',2);   
% 
%              else       
%                 pixelList = startBarcode:stopBarcode;
%                 %pixelList
%                % contigNum
%               %  startBarcode
%                 localMean = mean(refCurve(startBarcode:stopBarcode));
%                 localStd = std(refCurve(startBarcode:stopBarcode));
% 
%                 barc = barc*localStd+localMean;
%                   %  size(xx)
%                    % size(barc)
%                % length(pixelList)
%                % length(barc)
%                  plot(pixelList,barc,'linewidth',2,'color', colors(contigNum,:));
%             end
% 
%         end
%         %size(legendInfo)
%         %legend([h1{1} h1{2} ] ,legendInfo)
%         legend(legendInfo,'location', 'se');
%           
% %         if stopBarcode < startBarcode
% %             pixelList = [startBarcode:m];
% %             %size(xx)
% %             %size(barc)
% %             plot(pixelList,barc(1:length(pixelList)), 'r');
% %             xx2 = [1:stopBarcode];
% %             
% %             plot(xx2,barc(length(pixelList)+1:length(barc)), 'r','linewidth',2);   
% %             legendInfo{barcIndex+1} = ['contig' num2str(optimalBid(barcIndex,1))]; % or whatever is appropriate
% % 
% %         else
% %             pixelList = startBarcode:stopBarcode;
% %             localMean = mean(refCurve(startBarcode:stopBarcode));
% %             localStd = std(refCurve(startBarcode:stopBarcode));
% %             barc = barc*localStd+localMean;
% %           %  size(xx)
% %            % size(barc)
% %             plot(pixelList,barc,'linewidth',2);
% %             legendInfo{barcIndex+1} = ['contig' num2str(optimalBid(barcIndex,1))]; % or whatever is appropriate
% %         end
% 
%     end
%     
%     for contigNum=1:size(contigItems,2) % does not include flip option
%          startBarcode = round(contigItems{contigNum}.corPlacePxStart)+bit-0;
%          stopBarcode = round(contigItems{contigNum}.corPlacePxEnd);
%          if stopBarcode < startBarcode
%              pixelList = [startBarcode:length(refCurve) 1:stopBarcode]; 
%          else
%              pixelList = startBarcode:stopBarcode;
%          end
%          plot(pixelList,[ones(size(pixelList))*max(refCurve)],'linewidth',2,'color', colors(contigNum,:));
%     end
%          %        
%     
% 
%     ylabel('intensity')
%     ax = gca;
%     ticks = 1:50:length(refCurve);
%     ticksx = floor(ticks*592/1000);
%     ax.XTick = [ticks];
%     ax.XTickLabel = [ticksx];
%     xlabel('Position (kbp)')
%     
%     subplot(1,4,4);
%     %clear legendInfo;
% 
%     hold on;
%     numRem = 0;
%     for contigNum=1:size(contigItems,2) % does not include flip option
%         if	contigItems{contigNum}.isRemoved == 1 && numRem < 5;
%             startBarcode = round(contigItems{contigNum}.corPlacePxStart);
%             stopBarcode = round(contigItems{contigNum}.corPlacePxEnd);
%             plot(zscore(contigItems{contigNum}.barcode)/2+numRem,'linewidth',2,'color', colors(contigNum,:));
%             
%             pVal = min(pValueMatrix(contigNum,:));
%             
%  
%             %legendInfo{nInd+1} = ['contig' contigItems{contigNum}.name ', p-val=' num2str(pVal,'%.1e ')]; % or whatever is appropriate
%             legendInfo{numRem+1} = ['contig' contigItems{contigNum}.name ',cc=' num2str(max(ccValueMatrix(contigNum,:)),'%.2f ') ', p-val=' num2str(pVal,'%.2f ')]; % or whatever is appropriate
%             numRem = numRem+1;
%             
%         end
% 
%     end
%     %  legendInfo{contigNum+1} = ['contig' contigItems{contigNum}.name]; % or whatever is appropriate
%     %     legend(legendInfo,'location', 'sw')
%     legend(legendInfo,'location', 'sw','FontSize',8)
%     title({'Examples of'; 'removed contigs'})
%     %title({'Removed contigs'})

    
end

