function [ ] = plot_comparison(refCurve,optimalBid, revBi, barcodes,m,titleName )
% comparison graph plot
% 05/09/16 -- incldues check if we should reverse the contig


    figure;
    title(titleName)
    hold on;
    
    %refCurve2 = fliplr(refCurve);
    plot(refCurve, 'black');
    legendInfo = {};
    legendInfo{1} = ['refCurve']; % or whatever is appropriate

    for barcIndex=1:size(optimalBid,1) % does not include flip option
        startBarcode = optimalBid(barcIndex,2);
        stopBarcode = optimalBid(barcIndex,3);
        barc = barcodes{optimalBid(barcIndex,1)};
        barc = (barc -mean(barc))/std(barc);
        
        % nnz(revBi(optimalBid(barcIndex,1),optimalBid(barcIndex,2)))
        if nnz(revBi(optimalBid(barcIndex,1),optimalBid(barcIndex,2)))== 0
           barc = fliplr(barc); 
        end
        if stopBarcode < startBarcode
            xx = [startBarcode:m];
            plot(xx,barc(1:length(xx)), 'r');
            xx2 = [1:stopBarcode];
            
            plot(xx2,barc(length(xx)+1:length(barc)), 'r');   
            legendInfo{barcIndex+1} = ['seq' num2str(optimalBid(barcIndex,1))]; % or whatever is appropriate

        else
            xx = startBarcode:stopBarcode;

            plot(xx,barc);
            legendInfo{barcIndex+1} = ['seq' num2str(optimalBid(barcIndex,1))]; % or whatever is appropriate
        end

    end

    legend(legendInfo)



end

