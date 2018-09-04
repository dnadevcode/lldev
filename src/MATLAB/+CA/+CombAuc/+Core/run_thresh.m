function [placedTot,placedCor,settings] = run_thresh(theorySeq, expBarcode, meanFFT,settings)
    % This computes theory-experiment threshold. 
    % By plotting true positive rates
    
    if nargin < 1
        fprintf('Nothing selectd...\n');
        return;
    end
    
    if nargin < 4
    	settings = CA.Core.Settings.settings_thresh(); 
    end
    
    % These can be freely updated in the settings file or using a
    % user-promt (to be done)
    
    % these should be defined beforehand maybe..
    settings.contigSizeAllPos =  24000:2000:60000;
    settings.lengthBarcode = length(expBarcode);
    
    import CA.CombAuc.Core.Zeromodel.create_px_barcode
    [barcodeBpRes,barcodePxRes ] = create_px_barcode(theorySeq, settings.psfSigmaWidth,settings.kbpPerPixel,'old');

    % shift exp barcode by shiftBp bp and rescale
  %  expBarcode =  zscore( circshift(expBarcode,[0,-round(settings.shiftBp/(settings.kbpPerPixel ))]));
    
    placedTot = [];
    placedCor = [];
    
    for contigSizeInBp = settings.contigSizeAllPos
        
        import CA.CombAuc.Core.Comparison.gen_fake
        settings.contigLen = contigSizeInBp;
        %settings.lengthBarcode = length(barcodePxRes);
        contigItems = gen_fake(barcodeBpRes, settings);

        ccValueMatrix = zeros(length(contigItems), 2*length(expBarcode));

        for contigNum=1:length(contigItems)
            
            import CA.CombAuc.Core.Comparison.cc_fft % simplified corr coef calculation..
            [cc1,cc2] = cc_fft(zscore(contigItems{contigNum}.barcode), expBarcode);
            ccValueMatrix(contigNum,:) = [cc1 cc2];
        end
        
        placedE = [];
        corPlE = [];
        for numE = 1:settings.randomTries;
            import CA.CombAuc.Core.Zeromodel.generate_random_sequences;
            [ randomSequences ] = generate_random_sequences(2*round((contigSizeInBp-2*settings.uncReg)/(settings.kbpPerPixel)),1000,meanFFT, settings.psfSigmaWidth/(settings.kbpPerPixel ),'phase');
            for i=1:length(randomSequences)
                randomSequences{i} = zscore(randomSequences{i}(1:end/2));
            end
            
            import CA.CombAuc.Core.Comparison.compute_correlation;
            [ccMax,~] = compute_correlation(round((contigSizeInBp-2*settings.uncReg)/(settings.kbpPerPixel)), length(expBarcode),  'shortPrec', settings.psfSigmaWidth/(5*settings.kbpPerPixel ),randomSequences,expBarcode);

            import CA.CombAuc.Core.Comparison.generate_evd_par;
            [~,~,evdPar] = generate_evd_par( ccMax,[],(contigSizeInBp-2*settings.uncReg)/(5*settings.kbpPerPixel), 'exact2' );
% 
             pValueMatrix = ones(length(contigItems),2*length(expBarcode));
             
             import CA.CombAuc.Core.Comparison.compute_p_value;

            for contigNum=1:length(contigItems)
                pValueMatrix(contigNum,:) = compute_p_value(ccValueMatrix(contigNum,:),evdPar,'exact'); 
            end

            [values,indices] = min(transpose(pValueMatrix));
           % settings.dist = 3;
            placed = 0;
            corPl = 0;
            for iInd=1:length(values)
                if values(iInd) < settings.pValueThresh
                    placed = placed+1;
                    if norm( mod(contigItems{iInd}.corPlacePxStart,length(expBarcode))-mod(indices(iInd),length(expBarcode)))<  settings.dist 
                        corPl = corPl +1;
                    end
                end
            end
            placedE = [placedE placed];
            corPlE = [corPlE corPl];
        end
%         
%       %  Plot.plot_correct_placement(contigItems,contigSizeInBp,ccValueMatrix,pValueMatrix, refBarcode);
%                     
        placedTot = [placedTot; placedE];
        placedCor = [placedCor; corPlE];
    end
    
    
%     
%     resMat = placedTot./length(expBarcode);
% 
%     mMean = mean(transpose(resMat));
%     sStd =  std(transpose(resMat));
% 
%     h = figure, 
% 
%     errorbar(contigSizeInBp,mMean,sStd) 
%     hold on   
% 
%     resMat = placedCor./length(expBarcode);
% 
%     mMean = mean(transpose(resMat));
%     sStd =  std(transpose(resMat));
%     errorbar(contigSize,mMean,sStd) 
% 
%     resMat2 = placedCor./placedTot;
%     mMean2 = mean(transpose(resMat2));
%     sStd2 =  std(transpose(resMat2));
%     errorbar(contigSizeInBp,mMean2,sStd2);
% 
%     ysp =0:0.01:1;
%     plot(contigSizeInBp,repmat(0.99,1,length(contigSizeInBp)),'-.','color','black')
%     plot(repmat(43000,1,length(ysp)),ysp,'-.','color','g')
%     ylim([0 1])
% 
%     legend({'number of placed/total','number of correctly placed/total', 'number of correctly placed/placed',strcat(['1-p_{thresh}' ' = 0.99']) },'Location', 'southeast','Interpreter','latex')
%     xlabel('Contig size (bp)','Interpreter','latex')
%     ylabel('Ratio','Interpreter','latex')
%     seqN = {'pUUH', 'plos005A', 'plos005B','Chromosomal dna'};
% 
%     title(strcat([seqN{ind} ', synthetic contig assembly statistics']),'Interpreter','latex');
%     text(0.4,0.15,'l_{T-E}','units','normalized','FontSize',10)
% 

% 
    %
    % Assignment Problem
% 
%     fprintf('Running Assignment CAT...\n');
% 
%     nt = 1;
%     %load Consensus_pUUH.mat
%     %---User input---
% 
%     if nt == 0
%         %currentFolder = pwd;
%         [consensusFilenames, dirpath] = uigetfile({'*.mat;'; '*.txt;'}, 'Select consensus barcode',pwd);
%         barcodeStructure = load(consensusFilenames);
%         
%         expBarcode = barcodeStructure.barcode;
%         
%         if isempty(expBarcode)
%             fprintf('No reference consensus was provided\n');
%             return;
%         end
%         % Rescale reference curve
%         expBarcode = zscore(expBarcode);
% 
%         [consensusFilename, dirpath] = uigetfile({'*.mat;'; '*.txt;'}, 'Select consensus barcode',pwd);
%         contigStructure = load(consensusFilename);
%     else
%       %  dataStruct = load('Consensus_pUUH.mat' );
%         seqNames = {'correct_alignment_consensus.mat', 'correct_alignment_plos005a.mat', 'correct_alignment_plos005b.mat','correct_alignment_consensus.mat'};
%         plNames = {'plasmid_puuh.mat','plasmid_plos005a.mat','plasmid_plos005b.mat' ,'chromosomal.mat'};
%         
%         ind = 4;
%         dataStruct = load(seqNames{ind});
%         expBarcode = dataStruct.barcode;
%         plasmidStr = load(plNames{ind});
%         theorySeq = plasmidStr.plasmid;
%         settings = Settings.settings(); %
%         settings.contigSizeAllPos =  24000:10000:60000;
%         settings.lengthBarcode = length(expBarcode);
% 
%         % first get a Bp and Px resolution of the barcode we want to have fake
%         % statistics of. In this case it is plasmid
%         [barcodeBpRes,barcodePxRes ] = Zeromodel.create_px_barcode(theorySeq, settings,'old');
%         %refBarcode = barcodePxRes;
%     end
%     
%     %load('meanFFT_140116.mat');
%     
%     import Plot.plot_contigs;
%     import Cap.create_best_value_p_value_matrix;
% 
%     contigSize = settings.contigSizeAllPos;
%     
%     %contigSize = 50000;
%     
%     placedTot = [];
%     placedCor = [];
%     for contigSizeInBp = contigSize
%         settings.uncReg =3347;
%         import Comparison.gen_fake
%         settings.contigLen = contigSizeInBp;
%         settings.lengthBarcode = length(barcodePxRes);
%         contigItems = gen_fake(barcodeBpRes, settings);
%         
%         ccValueMatrix = zeros(length(contigItems),2*length(expBarcode));
% 
%         for contigNum=1:length(contigItems)
%             [cc1,cc2] = Comparison.cc_fft(zscore(contigItems{contigNum}.barcode),expBarcode);
%             ccValueMatrix(contigNum,:) = [cc1 cc2];
%         end
%         
%         placedE = [];
%         corPlE = [];
%         for numE = 1:2
% 
%             [ randomSequences ] = Zeromodel.generate_random_sequences(2*round((contigSizeInBp-2*settings.uncReg)/(settings.bpPerNm*settings.camRes)),1000,meanFFTest, settings.psfSigmaWidth/(settings.bpPerNm*settings.camRes ),'phase');
%             for i=1:length(randomSequences)
%                 randomSequences{i} = zscore(randomSequences{i}(1:end/2));
%             end
%             [ccMax,~] = Comparison.compute_correlation(round((contigSizeInBp-2*settings.uncReg)/(settings.bpPerNm*settings.camRes)), length(expBarcode),  'shortPrec', settings.psfSigmaWidth/(5*settings.bpPerNm*settings.camRes ),randomSequences,expBarcode);
%             [~,~,evdPar] = Comparison.generate_evd_par( ccMax,[],(contigSizeInBp-2*settings.uncReg)/(5*settings.bpPerNm*settings.camRes), 'exact2' );
% 
%             pValueMatrix = ones(length(contigItems),2*length(expBarcode));
% 
%             for contigNum=1:length(contigItems)
%                 pValueMatrix(contigNum,:) = Comparison.compute_p_value(ccValueMatrix(contigNum,:),evdPar,'exact'); 
%             end
% 
%             [values,indices] = min(transpose(pValueMatrix));
%             dist = 1;
%             placed = 0;
%             corPl = 0;
%             for iInd=1:length(values)
%                 if values(iInd) < settings.pValueThresh
%                     placed = placed+1;
%                     if norm( mod(contigItems{iInd}.corPlacePxStart,length(expBarcode))-mod(indices(iInd),length(expBarcode)))<  dist 
%                         corPl = corPl +1;
%                     end
%                 end
%             end
%             placedE = [placedE placed];
%             corPlE = [corPlE corPl];
%         end
%         
%       %  Plot.plot_correct_placement(contigItems,contigSizeInBp,ccValueMatrix,pValueMatrix, refBarcode);
%                     
%         placedTot = [placedTot; placedE];
%         placedCor = [placedCor; corPlE];
%     end
%   %  plot_contigs(refBarcode,contigItems, 'Contig placement');
%    % placedCor
%    % placedTot
%    
% 
%     resMat = placedTot./length(expBarcode);
% 
%     mMean = mean(transpose(resMat));
%     sStd =  std(transpose(resMat));
%     h = figure, 
% 
% 
% 
%     errorbar(contigSize,mMean,sStd) 
%     hold on   
% 
%     resMat = placedCor./length(expBarcode);
% 
%     mMean = mean(transpose(resMat));
%     sStd =  std(transpose(resMat));
%     errorbar(contigSize,mMean,sStd) 
% 
%     resMat2 = placedCor./placedTot;
%     mMean2 = mean(transpose(resMat2));
%     sStd2 =  std(transpose(resMat2));
%     errorbar(contigSize,mMean2,sStd2);
% 
%     ysp =0:0.01:1;
%     plot(contigSize,repmat(0.99,1,length(contigSize)),'-.','color','black')
%     plot(repmat(43000,1,length(ysp)),ysp,'-.','color','g')
%     ylim([0 1])
% 
%     legend({'number of placed/total','number of correctly placed/total', 'number of correctly placed/placed',strcat(['1-p_{thresh}' ' = 0.99']) },'Location', 'southeast','Interpreter','latex')
%     xlabel('Contig size (bp)','Interpreter','latex')
%     ylabel('Ratio','Interpreter','latex')
%     seqN = {'pUUH', 'plos005A', 'plos005B','Chromosomal dna'};
% 
%     title(strcat([seqN{ind} ', synthetic contig assembly statistics']),'Interpreter','latex');
%     text(0.4,0.15,'l_{T-E}','units','normalized','FontSize',10)
% 
% 
%     currentFolder = pwd;
%     datetime = datestr(now);
%     datetime=strrep(datetime,' ','');%Replace space with underscore
% 
%     name = strcat([currentFolder '/truerate' datetime '.mat']);
%     save(name, '-v7.3', 'refBarcode','contigSize','placedCor', 'placedTot','ind','datetime' );
% 
%     name = strcat([currentFolder '/truerate' datetime '.eps']);
%     saveas(h,name, 'epsc')
% 
% %

end