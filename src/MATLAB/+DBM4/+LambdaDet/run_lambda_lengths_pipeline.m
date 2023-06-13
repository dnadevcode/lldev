function [dbmStruct,dbmOSW] = run_lambda_lengths_pipeline(userDir,dbmOSW)

    %     run_lambda_lengths_pipeline
    %       LAMBDA's detection pipeline

    if nargin < 2
        import DBM4.UI.find_default_settings_path;
        defaultSettingsFilepath = find_default_settings_path('DBMnew.ini');
        import Fancy.IO.ini2struct;
        dbmOSW.DBMSettingsstruct = ini2struct(defaultSettingsFilepath);
    else
         dbmOSW.DBMSettingsstruct = dbmOSW;
    end
    dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm';  % hardcode settigns for lambda detection
    dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;
    dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;
    dbmOSW.DBMSettingsstruct.detectlambdas = 1;
    dbmOSW.DBMSettingsstruct.auto_run = 1;


    mFilePath = mfilename('fullpath');
    mfolders = split(mFilePath, {'\', '/'});
    dbmOSW.DBMSettingsstruct.versionLLDEV = importdata(fullfile(mfolders{1:end-5},'VERSION'));


    % dbm settings
    useGUI = 0;

    % change default alignment settings for lambda detection
    sets.minOverlap = 50;
    sets.maxShift = 20;
    sets.skipPreAlign = 1;
    sets.detPeaks = 0;


    % nmPx = 254; % extract from .ini file
    lambdaLenSeq = 48502 ;
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
%     d = dir(userDir);
%     dfolders = d([d(:).isdir]);
%     dfolders = dfolders(~ismember({dfolders(:).name},{'.','..'}));
%     
    dfolders(1).folder = userDir; % just the single folder with images.
    dfolders(1).name = ''; % just the single folder with images.

%     display(strcat([num2str(length(dfolders)) ' number of folders to run']));
    
    import DBM4.gen_barcodes_from_kymo;
    import Core.hpfl_extract;
    import OptMap.KymoAlignment.SPAlign.spalign;
    import DBM4.LambdaDet.compare_lambda_to_theory;
    import DBM4.LambdaDet.lambda_rand;

   
    % loop over folders
for idFold = 1:length(dfolders) % for now will be a single.
%     display(strcat(['Runnning fold ' num2str(idFold) ' out of '  num2str(length(dfolders)) ]));

    info = [];
    
    files = dir(fullfile(dfolders(idFold).folder,dfolders(idFold).name,'*.tif'));
    if isempty(files) % if no converted tifs, look for czi
        files = dir(fullfile(dfolders(idFold).folder,dfolders(idFold).name,'*.czi'));
    end
    info.foldName = dfolders(idFold).name;
    filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);

%     % generate info files / one-liner
%     infoFile = cellfun(@(x) imfinfo(x),filesC,'un',false); % doesn't give
% 
%     % todo: change to case
%     if isequal(infoFile{1}(1).ResolutionUnit,'None')
%         nmPx =  1/infoFile{1}(1).XResolution*1000; % this could be instead taken from metadata file, where it's given in Scaling|Distance|Value
%     else
%         if isequal(infoFile{1}(1).ResolutionUnit,'Centimeter')
%             nmPx =  1/infoFile{1}(1).XResolution*10^7;
%         else
% %             if isequal(infoFile{1}(1).ResolutionUnit,'Inch')
% %                 nmPx =  1/infoFile{1}(1).XResolution*10^7;
% % 
% %             else
%                 nmPx =  1/infoFile{1}(1).XResolution*1000; % this could be instead taken from metadata file, where it's given in Scaling|Distance|Value
% %             end
% 
%         end
%     end
    


 
%     if dbmOSW.DBMSettingsstruct.nmPerPixel~=nmPx
%         warning('Strange nm/px ratio in the info file');
        nmPx = dbmOSW.DBMSettingsstruct.nmPerPixel;
%     end
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
    sets.maxLen = lambdaLenSeq/(nmPx/nmbpLim(2)); % estimate for max length
    sets.minLen = lambdaLenSeq/(nmPx/nmbpLim(1)); % estimate for min length
    %     % sets.minLen
    [barcodeGen,acceptedBars] =  gen_barcodes_from_kymo(kymoStructs, sets,sets.maxLen);

    % background mean and standard deviation
    bgMean = cell2mat(dbmStruct.kymoCells.threshval(acceptedBars));
    bgStd = cell2mat(dbmStruct.kymoCells.threshstd(acceptedBars));
    dbmStruct.barcodeGen = barcodeGen;
    
    % Compare to theory  random/ put to function
    if dbmOSW.DBMSettingsstruct.autothreshLambda
        try
        [barRand] = lambda_rand(dbmStruct,barcodeGen, dbmStruct.kymoCells.threshval(acceptedBars), dbmOSW.DBMSettingsstruct.numrandlambda,dbmOSW.DBMSettingsstruct.nEdge);
        [dataStorageRand, nmbpHistRand, lambdaLenRand] = compare_lambda_to_theory(barRand,zeros(1,length(barRand)),curSetsNMBP, 1, stretchFactors, nmPx,nmPsf, BP, threshScore,atPref);
        threshScore = nanmedian(dataStorageRand{1}.score)-3*nanstd(dataStorageRand{1}.score);
        catch
            warning('Failed in detecting autothresh for lambda');
        end
    end

    % find nm/nb    
    [dataStorage, nmbpHist, lambdaLen] = compare_lambda_to_theory(barcodeGen,bgMean,curSetsNMBP, NN, stretchFactors, nmPx,nmPsf, BP, threshScore,atPref);
    
    targetFolder = fullfile(dfolders(idFold).folder, info.foldName, strcat(['analysis_' info.foldName]));
    [~,~] = mkdir(targetFolder);

%     info = [];
    info.threshScore = threshScore;
    info.idFold = idFold;
    info.bgMean = bgMean;
    info.bgStd = bgStd;
    info.acceptedBars = acceptedBars;
    info.targetFolder = targetFolder;
    info.kymoFoldName ='kymo';
    info.barFoldName = 'comparison';
    info.sets = dbmOSW.DBMSettingsstruct;
    info.setsAlign = sets;

    import DBM4.LambdaDet.export_lambda_res;
    [info] = export_lambda_res(dbmStruct,nmbpHist,lambdaLen,dataStorage,info,barcodeGen,filtKymo,filtBitmask);
    
    DBMSettingsstruct = dbmOSW.DBMSettingsstruct;
    DBMMainstruct = dbmStruct;
    DBMMainstruct.kymoStructs = kymoStructs;
    DBMMainstruct.barcodeGen = barcodeGen;
    DBMMainstruct.dataStorage = dataStorage;
    DBMMainstruct.info = info;
     dbmOSW.DBMSettingsstruct.info = info;
    dbmStruct.info = info;
    for j=1:length(DBMMainstruct.fileCells)
        DBMMainstruct.fileCells{j}.preCells = [];% save some space by not printing this
    end
    % always save session data as DBM loadable. kymoStructs possibly saved
    % twice (also in dbmStruct)
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    save(fullfile(targetFolder,['lambda_session_data',timestamp,'.mat']),'DBMMainstruct','DBMSettingsstruct')
    disp(['Data saved at ',targetFolder ])


end

