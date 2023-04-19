function [] = run_lambda_lengths_pipeline(userDir,dbmOSW)

    %     run_lambda_lengths_pipeline
    %       LAMBDA's detection pipeline

    if nargin < 2
        import OldDBM.General.SettingsWrapper;
        defaultSettingsFilepath = SettingsWrapper.get_default_newDBM_ini_filepath();
        if not(exist(defaultSettingsFilepath, 'file'))
        defaultSettingsFilepath = '';
        end
        dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);
    else
         dbmOSW.DBMSettingsstruct = dbmOSW;
    end
    dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm';  % hardcode settigns for lambda detection
    dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;
    dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;
    dbmOSW.DBMSettingsstruct.detectlambdas = 1;
    dbmOSW.DBMSettingsstruct.auto_run = 1;


    % dbm settings
    useGUI = 0;

    % change default alignment settings for lambda detection
    sets.minOverlap = 50;
    sets.maxShift = 20;
    sets.skipPreAlign = 1;
    sets.detPeaks = 0;


    % nmPx = 254; % extract from .ini file
    lambdaLen = 48502 ;
%     nmbp = 0.22; % initial nm/bp

    nmbpLim = [0.15 0.3];
    sets.skipEdgeDetection = 0;
    sets.bitmasking.untrustedPx = 6; % depending on nm/bp


    % for comparison with theory
    curSetsNMBP = 0.22; % initial nmbp
    NN = 10; % how many times to recalculate
    stretchFactors = 0.8:0.01:1.2; % how much rescale to allow
    nmPsf = 300;
    threshScore =  dbmOSW.DBMSettingsstruct.threshScore; % thresh for which bars to keep / only if autothreshLambda is off
    atPref = dbmOSW.DBMSettingsstruct.atPref; % calc from a separate file
    


   BP = 50000; % extra bp left/right
    %     fastawrite(theoryFile, [repmat('A',1,BP) a.Sequence repmat('A',1,BP)]);
   

    % get all folders we should run through
    d = dir(userDir);
    dfolders = d([d(:).isdir]);
    dfolders = dfolders(~ismember({dfolders(:).name},{'.','..'}));
    
    display(strcat([num2str(length(dfolders)) ' number of folders to run']));
    
    import DBM4.gen_barcodes_from_kymo;
    import Core.hpfl_extract;
    import OptMap.KymoAlignment.SPAlign.spalign;
    import DBM4.LambdaDet.compare_lambda_to_theory;
    import DBM4.LambdaDet.lambda_det_print;
    import DBM4.LambdaDet.lambda_rand;
    import Core.barcodes_snr;

   
    % loop over folders
for idFold = 1:length(dfolders)
    display(strcat(['Runnning fold ' num2str(idFold) ' out of '  num2str(length(dfolders)) ]));

    info = [];
    
    files = dir(fullfile(dfolders(idFold).folder,dfolders(idFold).name,'*.tif'));
    info.foldName = dfolders(idFold).name;
    filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);

    % generate info files / one-liner
    infoFile = cellfun(@(x) imfinfo(x),filesC,'un',false); % doesn't give

    % todo: change to case
    if isequal(infoFile{1}(1).ResolutionUnit,'None')
        nmPx =  1/infoFile{1}(1).XResolution*1000; % this could be instead taken from metadata file, where it's given in Scaling|Distance|Value
    else
        if isequal(infoFile{1}(1).ResolutionUnit,'Centimeter')
            nmPx =  1/infoFile{1}(1).XResolution*10^7;
        else
%             if isequal(infoFile{1}(1).ResolutionUnit,'Inch')
%                 nmPx =  1/infoFile{1}(1).XResolution*10^7;
% 
%             else
                nmPx =  1/infoFile{1}(1).XResolution*1000; % this could be instead taken from metadata file, where it's given in Scaling|Distance|Value
%             end

        end
    end
    


 
    if dbmOSW.DBMSettingsstruct.nmPerPixel~=nmPx
        warning('Strange nm/px ratio in the info file');
        nmPx = dbmOSW.DBMSettingsstruct.nmPerPixel;
    end
%     dbmOSW.DBMSettingsstruct.nmPerPixel = nmPx(1); % check if all the same
    info.nmpx = dbmOSW.DBMSettingsstruct.nmPerPixel;

    % detect molecules
    dbmOSW.DBMSettingsstruct.movies.movieNames = filesC;

%     dna_barcode_matchmaker(0,dbmOSW); % if we want to plot results in GUI

    % extract
    [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(dbmOSW.DBMSettingsstruct);

    
    info.numKymos = length(dbmStruct.kymoCells.rawKymos);

    filtKymo = dbmStruct.kymoCells.rawKymos;
    filtBitmask = dbmStruct.kymoCells.rawBitmask;
    names = dbmStruct.kymoCells.rawKymoName;
    

    kymoStructs = cell(1,length(filtKymo));
    for i=1:length(filtKymo)
        kymoStructs{i}.unalignedKymo = filtKymo{i};
        kymoStructs{i}.unalignedBitmask = filtBitmask{i};

        [kymoStructs{i}.alignedKymo,kymoStructs{i}.alignedMask,~,~] = ...
        spalign(double(filtKymo{i}),filtBitmask{i},sets.minOverlap,sets.maxShift,sets.skipPreAlign, sets.detPeaks);
        try
        kymoStructs{i}.leftEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'first'), 1:size(kymoStructs{i}.alignedMask,1));
        kymoStructs{i}.rightEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'last'), 1:size(kymoStructs{i}.alignedMask,1));
        catch
            kymoStructs{i}.leftEdgeIdxs = [];
            kymoStructs{i}.rightEdgeIdxs = [];
        end
        kymoStructs{i}.name = names{i};
    end


%     bppx = nmPx/nmbp;

%     lambdaPx = lambdaLen/bppx;
    %     % generate barcodes
    sets.maxLen = lambdaLen/(nmPx/nmbpLim(2)); % estimate for max length
    sets.minLen = lambdaLen/(nmPx/nmbpLim(1)); % estimate for min length
    %     % sets.minLen
    [barcodeGen,acceptedBars] =  gen_barcodes_from_kymo(kymoStructs, sets,sets.maxLen);

    % background mean and standard deviation
    bgMean = cell2mat(dbmStruct.kymoCells.threshval(acceptedBars));
    bgStd = cell2mat(dbmStruct.kymoCells.threshstd(acceptedBars));
 
    
    % Compare to theory  random/ put to function
    if dbmOSW.DBMSettingsstruct.autothreshLambda
        try
        [barRand] = lambda_rand(dbmStruct,barcodeGen, dbmStruct.kymoCells.threshval(acceptedBars), dbmOSW.DBMSettingsstruct.numrandlambda);
        [dataStorageRand,nmbpHistRand,lambdaLenRand] = compare_lambda_to_theory(barRand,zeros(1,length(barRand)),curSetsNMBP, 1, stretchFactors, nmPx,nmPsf, BP, threshScore,atPref);
        threshScore = median(dataStorageRand{1}.score)-3*std(dataStorageRand{1}.score);
        catch
            warning('Failed in detecting autothresh for lambda');
        end
    end

    % find nm/nb    
    [dataStorage, nmbpHist, lambdaLen] = compare_lambda_to_theory(barcodeGen,bgMean,curSetsNMBP, NN, stretchFactors, nmPx,nmPsf, BP, threshScore,atPref);
    
    targetFolder = fullfile(dfolders(idFold).folder, info.foldName, strcat(['analysis_' info.foldName]));

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
    mkdir(targetFolder);
    % info.snrind(idxses)
    printName = lambda_det_print(targetFolder, info, barcodeGen, idFold,molLengths);
    
    % save kymos
    % mkdir(targetFolder,num2str(idFold));
    
    % targetFolder = fullfile(targetFolder,num2str(idFold));
        files = cellfun(@(rawKymo, outputKymoFilepath)...
        isfile(fullfile(targetFolder,outputKymoFilepath)),...
        dbmStruct.kymoCells.enhanced(acceptedBars(idxses)), dbmStruct.kymoCells.rawKymoName(acceptedBars(idxses)));
    
        if sum(files) > 0
            cellfun(@(rawKymo, outputKymoFilepath)...
            delete(fullfile(targetFolder,outputKymoFilepath)),...
            dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
        end
            
    cellfun(@(rawKymo, outputKymoFilepath)...
    imwrite(uint16(round(double(rawKymo)./max(rawKymo(:))*2^16)), fullfile(targetFolder,outputKymoFilepath), 'tif','WriteMode','append'),...
    dbmStruct.kymoCells.rawKymos(acceptedBars(idxses)), dbmStruct.kymoCells.rawKymoName(acceptedBars(idxses)));
    
%     timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
%     save(fullfile(targetFolder,['lambda_session_data',timestamp,'.mat']),'barcodeGen','kymoStructs','dataStorage')




    %% Plot comparison?
        
        % plot
        for idx = idxses;
        curBar = imresize(barcodeGen{idx}.rawBarcode,'Scale' ,[1 bestBarStretch(idx)]) ;
        
        if rezMaxM{idx}.or==2
            curBar = fliplr(curBar);
        end
        
        curBar = curBar - bgMean(idx);
        curBar = curBar/max(curBar);
        
        f = figure('visible','off');
        plot( [lambdaScaled])
        hold on
        plot(rezMaxM{idx}.pos:rezMaxM{idx}.pos+length(curBar)-1,curBar)
        saveas(f,fullfile(targetFolder,['bar_comparison_' num2str(idx) '.png']));
        
        end
        
    end
    
    % always save session data as DBM loadable. kymoStructs possibly saved
    % twice (also in dbmStruct)
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    save(fullfile(targetFolder,['lambda_session_data',timestamp,'.mat']),'dbmStruct','dbmOSW','barcodeGen','kymoStructs','dataStorage')
    disp(['Data saved at ',targetFolder ])


end

