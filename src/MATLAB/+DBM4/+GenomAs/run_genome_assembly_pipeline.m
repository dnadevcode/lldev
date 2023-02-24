function [] = run_genome_assembly_pipeline(userDir)

    files = dir(fullfile(userDir,'*.tif'));

    useGUI = 0;
    
    % todo: settigns should be taken directly from settings file and not
    % initiated here. For easier end-use

    import OldDBM.General.SettingsWrapper;
    defaultSettingsFilepath = SettingsWrapper.get_default_newDBM_ini_filepath();
    if not(exist(defaultSettingsFilepath, 'file'))
        defaultSettingsFilepath = '';
    end
    dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);

    dbmOSW.DBMSettingsstruct.dbmtool = 'hpfl-odm'; 
    dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;

    dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;
    
    dbmOSW.DBMSettingsstruct.detectlambdas = 0;
    dbmOSW.DBMSettingsstruct.initialAngle = 0;
    dbmOSW.DBMSettingsstruct.maxLambdaLen = inf;
    dbmOSW.DBMSettingsstruct.angleStep = 0.01;
    dbmOSW.DBMSettingsstruct.numPts = 200;
    dbmOSW.DBMSettingsstruct.auto_run = 1;
    dbmOSW.DBMSettingsstruct.npeaks = 1;
    
    %% align
    sets.minOverlap = 300;
    sets.maxShift = 20;
    sets.skipPreAlign = 0;
    sets.detPeaks = 1;
    
    %% generate barcodes
    sets.maxLen=Inf;
    sets.skipEdgeDetection = 0;
    sets.bitmasking.untrustedPx = 6; % depending on nm/bp
    sets.minLen = 400; % dependent on nm/px ratio

    filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);
    dbmOSW.DBMSettingsstruct.movies.movieNames = filesC;
    % dna_barcode_matchmaker(0,dbmOSW); % if we want to plot results in GUI

    % detect molecules
    import Core.hpfl_extract;
    [dbmStruct.fileCells, dbmStruct.fileMoleculeCells,dbmStruct.kymoCells] = hpfl_extract(dbmOSW.DBMSettingsstruct);
 
    %% re-calculate edges based on intensity & align
    kymo = dbmStruct.kymoCells.rawKymos;
    bitmask = dbmStruct.kymoCells.rawBitmask;
    names = dbmStruct.kymoCells.rawKymoName;
    kymoStructs = cell(1,length(kymo));
    for i=1:length(kymo)  
        kymoStructs{i}.unalignedBitmask = bitmask{i};
        kymoStructs{i}.unalignedKymo = kymo{i};
    end


    import OptMap.KymoAlignment.SPAlign.spalign;
    % kymoStructs = cell(1,length(filtKymo));
    for i=1:length(kymoStructs)
    %     i
        [kymoStructs{i}.alignedKymo,kymoStructs{i}.alignedMask,~,~] = ...
        spalign(double(kymoStructs{i}.unalignedKymo),kymoStructs{i}.unalignedBitmask,sets.minOverlap,sets.maxShift,sets.skipPreAlign, sets.detPeaks);
        kymoStructs{i}.leftEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'first'), 1:size(kymoStructs{i}.alignedMask,1));
        kymoStructs{i}.rightEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'last'), 1:size(kymoStructs{i}.alignedMask,1));
        kymoStructs{i}.name = names{i};
    end



    %     % sets.minLen
    import DBM4.gen_barcodes_from_kymo;
    barcodeGen =  gen_barcodes_from_kymo(kymoStructs, sets,sets.maxLen);

    %% Merge neighbor barcodes
    import DBM4.Bargrouping.merge_neighbor_barcodes;
    [barGenMerged,posMulti,cnt_unique] = merge_neighbor_barcodes(barcodeGen);

%     assignin('base','fileStructOut',fileStruct);
    outputTarget = strcat(userDir,'_sessiondata');
    mkdir(outputTarget);
%     assignin('base','dbmStruct',dbmStruct);
    save(fullfile(outputTarget,'session_data.mat'),'barcodeGen','barGenMerged','kymoStructs')

    files = cellfun(@(rawKymo, outputKymoFilepath)...
    isfile(fullfile(outputTarget,outputKymoFilepath)),...
    dbmStruct.kymoCells.enhanced, dbmStruct.kymoCells.rawKymoName);

    if sum(files) > 0
    cellfun(@(rawKymo, outputKymoFilepath)...
    delete(fullfile(outputTarget,outputKymoFilepath)),...
    dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
    end

    % cellfun(@(rawKymo, outputKymoFilepath)...
    % imwrite(uint16(round(double(rawKymo))), fullfile(outputTarget,outputKymoFilepath), 'tif','WriteMode','append'),...
    % dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
    % 
    cellfun(@(rawKymo, outputKymoFilepath)...
    imwrite(uint16(round(double(rawKymo)./max(rawKymo(:))*2^16)), fullfile(outputTarget,outputKymoFilepath), 'tif','WriteMode','append'),...
    dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);


    sF = 0.95:0.01:1.05;
    minOverlap = 300;
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');

    % bars = barGenMerged(length(posSingle):end);
    bars = barGenMerged(cellfun(@(x) sum(x.rawBitmask),barGenMerged)>300);
    [oS] = calc_overlap_mp(bars,sF, minOverlap,timestamp);
    
    save(fullfile(outputTarget,'mp_data.mat'),'minOverlap','oS','sF')


end
end

