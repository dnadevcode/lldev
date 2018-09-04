function [ h ] = plot_p_matrix( pMatrix,contigItems,refBarcode,name,colors,indexesToPlot)

    if nargin < 6
        indexesToPlot = 1:size(pMatrix,1);
    end
    
   % h = figure;
    %subplot(1,2,1)
    clear legendInfo
    hold on
    for i=indexesToPlot
     
        plot(pMatrix(i,:)+size(pMatrix,1)-i+1,'color',colors(i,:))
        legendInfo{i} = [contigItems{i}.name]; % or whatever is appropriate
    end
  %  subplot(1,2,2)
    legend(legendInfo,'location', 'se','Interpreter','latex')
    
    for i=indexesToPlot
        
        
        startBarcode = round(contigItems{i}.corPlacePxStart);
        stopBarcode = round(contigItems{i}.corPlacePxEnd);
         if stopBarcode < startBarcode
             pixelList = [startBarcode:length(refBarcode) 1:stopBarcode]; 
         else
             pixelList = startBarcode:stopBarcode;
         end
            plot(pixelList,[ones(size(pixelList))+size(pMatrix,1)-i+1],'linewidth',2,'color', 'black');

    end
    
    xx =1:0.1:length(indexesToPlot)+1;
    plot(repmat(length(refBarcode),1,length(xx)),xx, '-.')
    title(name,'Interpreter','latex');
    xlabel('Position (pixel)','Interpreter','latex');
    ylabel('Shifted p-values','Interpreter','latex');


end

