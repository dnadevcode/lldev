function [] = plot_correct_placement(contigItems,contigSizeInBp,ccValueMatrix,pValueMatrix, refBarcode,barcodePxRes,evdPar )

    corPlVec = [];
    for i=1:length(contigItems)
        corPlVec = [corPlVec contigItems{i}.corPlacePxStart];
    end

    [ccM,ccD] = max(transpose(ccValueMatrix));

    [pM, pD] =min( transpose(pValueMatrix));

    pPass = [];
    for i=1:length(contigItems)
        if pM(i) < 0.01
            pPass = [pPass i];
        end
    end



    h = figure( 'Visible','off');plot(mod(corPlVec,length(refBarcode)))
    hold on
    plot(mod(ccD,length(refBarcode)))

    plot(pPass,pPass,'.','color','b')
    
    title(strcat(strcat('Placement comparison for contigs of length= ',num2str(contigSizeInBp)),' bp'))
    legend({'correct place', 'place with best correlation coefficient value','p-value <0.01'},'Location', 'southeast')
    xlabel('Contig nr.')
    ylabel('Pixel')

    currentFolder = pwd;
    datetime=datestr(now);
    datetime=strrep(datetime,':','_'); %Replace colon with underscore
    datetime=strrep(datetime,'-','_');%Replace minus sign with underscore
    datetime=strrep(datetime,' ','_');%Replace space with underscore

    name = strcat([currentFolder '/PlacementStats ' num2str(contigSizeInBp) ' ' datetime '.mat']);
    save(name, '-v7.3','contigItems','evdPar', 'contigSizeInBp','pValueMatrix','corPlVec','pPass','ccValueMatrix','refBarcode','barcodePxRes','datetime');


    name = strcat([currentFolder '/PlacementStats' num2str(contigSizeInBp) num2str(randi(1000)) '.eps']);
    saveas(h,name, 'epsc')

end

