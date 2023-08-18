function [info] = export_lambda_res(dbmStruct,nmbpHist,lambdaLen,dataStorage,info,barcodeGen,filtKymo,filtBitmask)

    threshScore =  info.threshScore;
    idFold =  info.idFold;
    bgMean =  info.bgMean ;
    bgStd = info.bgStd ;
    acceptedBars =  info.acceptedBars ;
    targetFolder = info.targetFolder;
    kymoFoldName = info.kymoFoldName;
    barFoldName = info.barFoldName;

    
    import Core.barcodes_snr;
    import DBM4.LambdaDet.lambda_det_print;

if ~isempty(nmbpHist)
    molLengths = lambdaLen(end)./dataStorage{end}.bestBarStretch;
    %% 
    idxses = find(dataStorage{end}.score<threshScore);
    outFac=dataStorage{end}.bestBarStretch(idxses);
    % can run a few loops to converge on a specific value
    
    info.goodMols = idxses;
    info.stretchFac = outFac;
    info.score = dataStorage{end}.score(idxses);
    info.threshScore = threshScore;
    info.lambdaLen = lambdaLen;
    info.bestnmbpStd = dataStorage{end}.bestStrStd;

    %% plot:     
    bestBarStretch = dataStorage{end}.bestBarStretch;
    rezMaxM = dataStorage{end}.rezMaxM;
    lambdaScaled = dataStorage{end}.lambdaScaled;
    lambdaMask = dataStorage{end}.lambdaMask;
    
    % signal to noise ratio:
    estSNR = nan(1,length(barcodeGen));
    for ii=idxses
    %     curBar = imresize(barcodeGen{ii}.rawBarcode(barcodeGen{ii}.rawBitmask),'Scale' ,[1 bestBarStretch(ii)]) ;
    %     meanSignal = (mean(curBar)-bgMean(ii))/mean(lambdaScaled(find(lambdaMask)));
    %     stdBg = bgStd(ii);
        estSNR(ii) =  barcodes_snr(filtKymo{acceptedBars(ii)},filtBitmask{acceptedBars(ii)}, bgMean(ii), bgStd(ii));
    %     estSNR(ii) = meanSignal/stdBg;
    end
    
    info.snrind = estSNR(idxses);
    

    info.snr = nanmean(estSNR);
    info.nmbp = nmbpHist(end)
%     mkdir(targetFolder);
    % info.snrind(idxses)
    printName = lambda_det_print(targetFolder, info, barcodeGen, idFold,molLengths);
    
%     idxses = 1:length(acceptedBars);
    % save kymos
    [~,~] = mkdir(targetFolder,kymoFoldName);
    % targetFolder = fullfile(targetFolder,num2str(idFold));
        files = cellfun(@(rawKymo, outputKymoFilepath)...
        isfile(fullfile(targetFolder,kymoFoldName,outputKymoFilepath)),...
        dbmStruct.kymoCells.enhanced(acceptedBars(idxses)), dbmStruct.kymoCells.rawKymoName(acceptedBars(idxses)));
    
        if sum(files) > 0
            cellfun(@(rawKymo, outputKymoFilepath)...
            delete(fullfile(targetFolder,kymoFoldName,outputKymoFilepath)),...
            dbmStruct.kymoCells.rawKymos(acceptedBars(idxses)), dbmStruct.kymoCells.rawKymoName(acceptedBars(idxses)));
        end
            
    cellfun(@(rawKymo, outputKymoFilepath)...
    imwrite(uint16(round(double(rawKymo)./max(rawKymo(:))*2^16)), fullfile(targetFolder,kymoFoldName,outputKymoFilepath), 'tif','WriteMode','append'),...
    dbmStruct.kymoCells.rawKymos(acceptedBars(idxses)), dbmStruct.kymoCells.rawKymoName(acceptedBars(idxses)));
    
%     timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
%     save(fullfile(targetFolder,['lambda_session_data',timestamp,'.mat']),'barcodeGen','kymoStructs','dataStorage')




    %% Plot comparison?
    [~,~] = mkdir(fullfile(targetFolder,barFoldName));

        % plot
%         idxses = 1:length(acceptedBars);
        for idx = 1:length(idxses); %length(idxses); % need to plot all for then to use recalc
%             hold off

            try
               f = figure('visible','off');
                hAxis = axes(f);

            curBar = imresize(barcodeGen{idxses(idx)}.rawBarcode,'Scale' ,[1 bestBarStretch(idxses(idx))]) ;
            
            if rezMaxM{idxses(idx)}.or==2
                curBar = fliplr(curBar);
            end
        
            curBar = curBar - bgMean(idxses(idx));
            curBar = curBar/max(curBar);
           % cla(hAxis)

            plot( [lambdaScaled],'LineWidth',2)
            hold on
            plot(rezMaxM{idxses(idx)}.pos:rezMaxM{idxses(idx)}.pos+length(curBar)-1,curBar,'LineWidth',2)
    %         saveas(f,fullfile(targetFolder,barFoldName,['bar_comparison_' num2str(idx) '.png']));
%             catch
%                 plot(1,1)
%             end   
            axisFrame = getframe(hAxis);
            axisImg = frame2im(axisFrame);
            imwrite(axisImg, fullfile(targetFolder,barFoldName,['bar_comparison_' num2str(idxses(idx)) '.png']));
            info.compName{idx} =  fullfile(targetFolder,barFoldName,['bar_comparison_' num2str(idxses(idx)) '.png']);
            catch
            end
%         f = figure('Visible','off');
%         hAxis = axes(f);
%         %             
%         import DBM4.Figs.disp_rect_image;
%         disp_rect_image(hAxis, dbmStruct.kymoCells.rawKymos{jj}, strrep(fe,'_','\_'))
%         %      
%             hAxis.YDir = 'reverse'; % show kymo's flowing down
% 
%             hold on
%             set(gca,'color',[0 0 0]);
%             set(hAxis,'XTick',[]);
%             set(hAxis,'YTick',[]);
%             [fb,fe] = fileparts(dbmStruct.kymoCells.rawKymoName{jj});
% 
%             plot_kymo_edges(hAxis,...
%             dbmStruct.kymoCells.kymosMoleculeLeftEdgeIdxs{jj}', ...
%             dbmStruct.kymoCells.kymosMoleculeRightEdgeIdxs{jj}');
%                 axisFrame = getframe(hAxis);
%             axisImg = frame2im(axisFrame);
%             imwrite(axisImg, fullfile(defaultStatsOutputDirpath,strrep(dbmStruct.kymoCells.rawKymoName{jj},'.tif','.png')));

        end
        
end


end

