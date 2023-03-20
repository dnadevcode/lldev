function printName = lambda_det_print(targetFolder, info,barcodeGen, runNo , lengths)
    % prints results as txt
    
    experiment.targetFolder = targetFolder;
    % Initiate printing - make file with corrects filename - make new file if old is present
    printName = print_version( experiment, runNo);
    
        
    xlsxName = strrep(printName,'.txt','.xlsx');
    try
        [~,~] = delete(xlsxName);
    catch
    end
    writecell({[info.foldName]}  ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(1) ] );
    writecell({'Num mols',[info.numKymos]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(2) ] );%,'WriteMode','append')
    writecell({'Num mols of suitable length',[length(barcodeGen)]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(3) ] );%,'WriteMode','append')

    writecell({'XResolution',[1000/info.nmpx]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(4) ] );%,'WriteMode','append')
    writecell({'Average length (micron)',[ mean(lengths)]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(5) ] );%,'WriteMode','append')
    writecell({'SNR',[ info.snr]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(6) ] );%,'WriteMode','append')
    writecell({'NM/BP',[info.nmbp]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(7) ] );%,'WriteMode','append')
    writecell({'NM/BP Standard deviation',[info.bestnmbpStd]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(8) ] );%,'WriteMode','append')

    writecell({'Idx accepted mols',num2str([info.goodMols])} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(9) ] );%,'WriteMode','append')
    writecell({'ThreshValue',[info.threshScore]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(10) ] );%,'WriteMode','append')

    writecell({'lambdaLen',[info.lambdaLen(end)]} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(11) ] );%,'WriteMode','append')

%     writecell({'Num mols','XResolution','Average length (micron)', 'SNR','NM/BP','Num accepted mols','ThreshValue'} ,strrep(printName,'.txt','.xlsx'),'Sheet','Lambda molecules','Range',['A', num2str(2) ] );%,'WriteMode','append')
    
%     writecell({[info.numKymos], [ 1000/info.nmpx],[ mean(lengths)], [ info.snr],[info.nmbp],[length(info.goodMols)],[info.threshScore] }  ,strrep(printName,'.txt','.xlsx'),'Sheet','Lambda molecules','Range',['A', num2str(3) ] );
% 
writecell({'Mol nr','Re-scale factor', 'Length (micron)', 'Score','SNR'} ,xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(13) ] );%,'WriteMode','append')
%      
    for jj=1:length(info.goodMols)
        writematrix([info.goodMols(jj) info.stretchFac(jj) lengths(info.goodMols(jj)) info.score(jj) info.snrind(jj) ],xlsxName,'Sheet','Lambda molecules','Range',['A', num2str(jj+14) ] );%,'WriteMode','append')

    end


  % Print overall results
  fid = fopen(printName, 'w');
  fprintf(fid, 'Results for the lambda analysis of of %s\n', info.foldName);
  fprintf(fid, '\n Total number of kymos: %i \n', info.numKymos);
  fprintf(fid, '\n Total number of barcodes of suitable length: %i \n',length(barcodeGen));

%   lengths = cellfun(@(x) length(x.rawBarcode),barcodeGen)*info.nmpx./1000;
  
    fprintf(fid, '\n Total length of barcodes: %.1f micrometer \n', sum(lengths));
    fprintf(fid, '\n Average length of barcodes: %.3f micrometer \n', mean(lengths));
    
    fprintf(fid, '----------------------------------------------------------------------- \n');
    fprintf(fid, '----------------------------------------------------------------------- \n');
    
    fprintf(fid, 'Analysis settings:\n');
    fprintf(fid, '\n XResolution for experiment: %.1f micrometer \n', 1000/info.nmpx);

    
%   lengthLims = output{1}.lengthLims;
%   widthLims = output{1}.widthLims;
%   fprintf(fid, ' Minimum molecule score      : %.3g (User set value) \n', experiment.lowLim);
%   fprintf(fid, ' Minimum dot score           : %.3g (User set value) \n', experiment.dotScoreMin);
%   fprintf(fid, ' Molecule length limits      : %.1f - %.1f pixels \n', lengthLims(1), lengthLims(2));
%   fprintf(fid, ' Molecule width limits       : %.1f - %.1f pixels \n', widthLims(1), widthLims(2));
%   fprintf(fid, ' Molecule eccentricity limit : %.2f \n', experiment.elim);
%   fprintf(fid, ' Min. mol-to-convex-hull     : %.2f \n', experiment.ratlim);
%   fprintf(fid, ' Min. dot to end distance    : %.1f pixels \n', experiment.dotMargin);
%     fprintf(fid, ' Mol extraction method    : %.1f \n', sets.extractionMethod);
% 
%   fprintf(fid, [' Optics settings             : NA = %.2f,' ...
%               ' pixel size = %.2f nm, \n' ...
%               '   wavelength = %.2f nm, sigma_psf = %.2f nm, sigma_LoG = %.2f nm. \n'], ...
%     optics.NA, optics.pixelSize, optics.waveLength, ...
%     optics.sigma * optics.pixelSize, optics.logSigma * optics.pixelSize);
% 
% 
% 
    fprintf(fid, strcat(['\n Total SNR : %4f']), info.snr);
    fprintf(fid, strcat(['\n Estimated NM/BP ratio : %4f']), info.nmbp);

      fprintf(fid, '\n Total number of barcodes with suitable score: %i \n',length(info.goodMols));

    fprintf(fid, '\n----------------------------------------------- \n');

for i=1:length(info.goodMols)
    fprintf(fid, strcat(['\n Barcode ' num2str(info.goodMols(i))]));% ' [micrometer length] : %4.3f']),imBarLengthAll{i}(jj));
    fprintf(fid, strcat(['\n Length (micron) : %4f']), lengths(info.goodMols(i)));
    fprintf(fid, strcat(['\n Length re-scale factor : %4f']),info.stretchFac(i));
    fprintf(fid, strcat(['\n Score : %4f']), info.score(i));
    fprintf(fid, strcat(['\n  SNR : %4f']), info.snrind(i));

    fprintf(fid, '\n----------------------------------------------- \n');
end
    fclose(fid);


end

function printName = print_version(experiment, runNo)

    folderName = experiment.targetFolder;
    
    nameType = 'results_lambda';
    
    version = runNo;
    printName = fullfile(folderName, [nameType, num2str(version), '.txt']);
end
