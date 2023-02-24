function [] = run_lambda_lengths_pipeline(userDir)

    %     run_lambda_lengths_pipeline
    %       LAMBDA's detection pipeline

    % get all folders we should run through
    d = dir(userDir);
    dfolders = d([d(:).isdir]);
    dfolders = dfolders(~ismember({dfolders(:).name},{'.','..'}));
    
    display(strcat([num2str(length(dfolders)) ' number of folders to run']));
    
   
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
            nmPx =  1/infoFile{1}(1).XResolution*1000; % this could be instead taken from metadata file, where it's given in Scaling|Distance|Value
        end
    end
    

    % dbm settings
    useGUI = 0;

    import OldDBM.General.SettingsWrapper;
    defaultSettingsFilepath = SettingsWrapper.get_default_newDBM_ini_filepath();
    if not(exist(defaultSettingsFilepath, 'file'))
        defaultSettingsFilepath = '';
    end
    dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);
    dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm'; 
    dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;
    dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;
    dbmOSW.DBMSettingsstruct.detectlambdas = 1;
    dbmOSW.DBMSettingsstruct.auto_run = 1;

    dbmOSW.DBMSettingsstruct.nmPerPixel = nmPx(1); % check if all the same
    info.nmpx = dbmOSW.DBMSettingsstruct.nmPerPixel;

    % detect molecules
    dbmOSW.DBMSettingsstruct.movies.movieNames = filesC;

%     dna_barcode_matchmaker(0,dbmOSW); % if we want to plot results in GUI

    % extract
    import Core.hpfl_extract;
    [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(dbmOSW.DBMSettingsstruct);

    
    info.numKymos = length(dbmStruct.kymoCells.rawKymos);

    filtKymo = dbmStruct.kymoCells.rawKymos;
    filtBitmask = dbmStruct.kymoCells.rawBitmask;
    names = dbmStruct.kymoCells.rawKymoName;
    
    %% align kymos // take these for settings for lambda..
    sets.minOverlap = 50;
    sets.maxShift = 20;
    sets.skipPreAlign = 1;
    sets.detPeaks = 0;
    import OptMap.KymoAlignment.SPAlign.spalign;
    kymoStructs = cell(1,length(filtKymo));
    for i=1:length(filtKymo)
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

    % nmPx = 254; % extract from .ini file
    lambdaLen = 48502 ;
    nmbp = 0.22;

    bppx = nmPx/nmbp;

    lambdaPx = lambdaLen/bppx;
    %     % generate barcodes
    sets.maxLen = lambdaLen/(nmPx/0.3); % estimate for max length
    sets.skipEdgeDetection = 0;
    sets.bitmasking.untrustedPx = 6; % depending on nm/bp
    sets.minLen = lambdaLen/(nmPx/0.15); % estimate for min length
    %     % sets.minLen
    import DBM4.gen_barcodes_from_kymo;
    [barcodeGen,acceptedBars] =  gen_barcodes_from_kymo(kymoStructs, sets,sets.maxLen);

    bgMean = cell2mat(dbmStruct.kymoCells.threshval(acceptedBars));
    bgStd = cell2mat(dbmStruct.kymoCells.threshstd(acceptedBars));

   BP = 50000; % extra bp left/right
    %     fastawrite(theoryFile, [repmat('A',1,BP) a.Sequence repmat('A',1,BP)]);
    
    import DBM4.LambdaDet.compare_lambda_to_theory;
    
        
    curSetsNMBP = 0.22; %
    NN = 10;
    stretchFactors = 0.8:0.01:1.2;
    nmPsf = 300;
    threshScore = 0.1;
    atPref = 16;
    
        
    [dataStorage,nmbpHist] = compare_lambda_to_theory(barcodeGen,bgMean,curSetsNMBP, NN, stretchFactors, nmPx,nmPsf, BP, threshScore,atPref);
        
    %% 
    idxses = find(dataStorage{end}.score<threshScore);
    outFac=dataStorage{end}.bestBarStretch(idxses)
    % can run a few loops to converge on a specific value
    
    info.goodMols = idxses;
    info.stretchFac = outFac;
    info.score = dataStorage{end}.score(idxses);
    
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
        import Core.barcodes_snr
        estSNR(ii) =  barcodes_snr(filtKymo{acceptedBars(ii)},filtBitmask{acceptedBars(ii)}, bgMean(ii), bgStd(ii))
    %     estSNR(ii) = meanSignal/stdBg;
    end
    
    info.snrind = estSNR(idxses);
    
    info.snr = nanmean(estSNR);
    info.nmbp = nmbpHist(end)
    targetFolder = strcat(['output_' info.foldName]);
    mkdir(targetFolder);
    % info.snrind(idxses)
    import DBM4.LambdaDet.lambda_det_print;
    printName = lambda_det_print(targetFolder, info,barcodeGen, idFold)
    
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

    end

end

