function [] = run_lambda_lengths_pipeline_recalc(dbmOSW,dbmStruct,tshAdd)
    % lambda_recalc using DBM's good/bad tool

info = dbmStruct.info;
kymoStructs = dbmStruct.kymoCells;
barcodeGen = dbmStruct.barcodeGen;

import Microscopy.UI.UserSelection.goodbadtool;
[allKymos] = goodbadtool([4 4], info.compName, [],[],dbmOSW,tshAdd);

goodKymosIdx = sum(allKymos.selected==1);
disp(['Keeping ', num2str(sum(goodKymosIdx)),' barcodes']);
% import DBM4.UI.good_mol_selection;
% [goodKymosIdx,info] = good_mol_selection([4 4],kymoStructs,info);

barcodeGen = barcodeGen(logical(goodKymosIdx));
bgMean =  dbmStruct.info.bgMean(logical(goodKymosIdx));
bgStd =  dbmStruct.info.bgStd(logical(goodKymosIdx));
threshScore =  dbmStruct.info.threshScore; % same threshscore

% for comparison with theory % TODO: put in settings
curSetsNMBP = 0.22; % initial nmbp
NN = 10; % how many times to recalculate
stretchFactors = 0.8:0.01:1.2; % how much rescale to allow
nmPsf = 300;
atPref = dbmOSW.atPref; % calc from a separate file
nmPx = info.nmpx;
targetFolder = info.targetFolder;

BP = 50000; % extra bp left/right
%     fastawrite(theoryFile, [repmat('A',1,BP) a.Sequence repmat('A',1,BP)]);

import DBM4.LambdaDet.compare_lambda_to_theory;

% find nm/nb    
[dataStorage, nmbpHist, lambdaLen] = compare_lambda_to_theory(barcodeGen,bgMean,curSetsNMBP, NN, stretchFactors, nmPx,nmPsf, BP, threshScore,atPref);
    
% targetFolder = fullfile(dfolders(info.idFold).folder, info.foldName, strcat(['analysis_' info.foldName]));
[~,~] = mkdir(targetFolder);

%     info = [];
%     info.threshScore = threshScore;
%     info.idFold = idFold;
    info.bgMean = bgMean;
    info.bgStd = bgStd;
    info.acceptedBars = find(goodKymosIdx);
    info.targetFolder = targetFolder;

    info.kymoFoldName ='kymo_sel';
    info.barFoldName = 'comparison_sel';

    filtKymo = dbmStruct.kymoCells.rawKymos;
    filtBitmask = dbmStruct.kymoCells.rawBitmask;

    info.idFold = '_r';
    import DBM4.LambdaDet.export_lambda_res;
    [info] = export_lambda_res(dbmStruct,nmbpHist,lambdaLen,dataStorage,info,barcodeGen,filtKymo,filtBitmask);
    
    DBMSettingsstruct = dbmOSW;
    DBMMainstruct = dbmStruct;
    for j=1:length(DBMMainstruct.fileCells)
        DBMMainstruct.fileCells{j}.preCells = [];% save some space by not printing this
    end
    % always save session data as DBM loadable. kymoStructs possibly saved
    % twice (also in dbmStruct)
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    save(fullfile(targetFolder,['lambda_session_data_recalc',timestamp,'.mat']),'DBMMainstruct','DBMSettingsstruct','barcodeGen','kymoStructs','dataStorage','info')
    disp(['Data saved at ',targetFolder ])


end

