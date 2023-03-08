function [barcodeGen,barGenMerged,kymoStructs] = run_genome_assembly_pipeline(userDir, dbmOSW, runMP)
    %   Args:
    %
    %   Returns:
    %       barcodeGen, 
    %       barGenMerged
    %       kymoStructs - kymo structure
    if nargin < 3
        runMP = 0;
    end

    if nargin < 2
        import OldDBM.General.SettingsWrapper;
        defaultSettingsFilepath = SettingsWrapper.get_default_newDBM_ini_filepath();
        if not(exist(defaultSettingsFilepath, 'file'))
            defaultSettingsFilepath = '';
        end
        dbmOSW = SettingsWrapper.import_dbm_settings_from_ini(defaultSettingsFilepath);
    end

    % specific settings
    dbmOSW.DBMSettingsstruct.askForDBMtoolSettings = 0;
    dbmOSW.DBMSettingsstruct.movies.askForMovies = 0;
    dbmOSW.DBMSettingsstruct.auto_run = 1;

    %% align
    sets.minOverlap =  dbmOSW.DBMSettingsstruct.minOverlap;
    sets.maxShift = dbmOSW.DBMSettingsstruct.maxShift;
    sets.skipPreAlign = dbmOSW.DBMSettingsstruct.skipPreAlign;
    sets.detPeaks = dbmOSW.DBMSettingsstruct.detPeaks;
    
    %% generate barcodes
    sets.maxLen=Inf;
    sets.skipEdgeDetection = 0;
    sets.bitmasking.untrustedPx = 6; % depending on nm/bp
    sets.minLen = max(dbmOSW.DBMSettingsstruct.minLen,sets.minOverlap); % dependent on nm/px ratio




    files = dir(fullfile(userDir,'*.tif'));

    % check if movies or kymos

    useGUI = 0;
    
    if ~isempty(files)
        isKymo = contains(files(1).name,'kymograph');
    else
        warning('No files in the folder');
        isKymo = 0;
    end

    
    filesC = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);
    dbmOSW.DBMSettingsstruct.movies.movieNames = filesC;
    % dna_barcode_matchmaker(0,dbmOSW); % if we want to plot results in GUI

    if ~isKymo
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

    else
        warning('Importing kymos (old format)')
        kymoStructs = cell(1,length(filesC));
        names = filesC;
        import OptMap.MoleculeDetection.EdgeDetection.approx_main_kymo_molecule_edges;
        edgeDetectionSettings.skipDoubleTanhAdjustment = 1;
%         edgeDetectionSettings.method = 'Zscore';
        for j=1:length(filesC) % todo:
            kymoStructs{j}.unalignedKymo  = imread(filesC{j},1);
            [ ~,~,  kymoStructs{j}.unalignedBitmask ] = approx_main_kymo_molecule_edges(kymoStructs{j}.unalignedKymo  , edgeDetectionSettings);       
         end
     end




    import OptMap.KymoAlignment.SPAlign.spalign;
    % kymoStructs = cell(1,length(filtKymo));
    badMasks = [];
    for i=1:length(kymoStructs)
    %     i
        try
        [kymoStructs{i}.alignedKymo,kymoStructs{i}.alignedMask,~,~,newMask] = ...
        spalign(double(kymoStructs{i}.unalignedKymo),kymoStructs{i}.unalignedBitmask,sets.minOverlap,sets.maxShift,sets.skipPreAlign, sets.detPeaks);
        if (sum(kymoStructs{i}.alignedMask(:))==0)
            kymoStructs{i}.alignedMask = kymoStructs{i}.unalignedBitmask; % there was a single feature
        end
        kymoStructs{i}.leftEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'first'), 1:size(kymoStructs{i}.alignedMask,1));
        kymoStructs{i}.rightEdgeIdxs = arrayfun(@(frameNum) find(kymoStructs{i}.alignedMask(frameNum, :), 1, 'last'), 1:size(kymoStructs{i}.alignedMask,1));
        kymoStructs{i}.name = names{i};
        kymoStructs{i}.len = sum(newMask');
        kymoStructs{i}.lenParams = polyfit(1:length(kymoStructs{i}.len ),kymoStructs{i}.len ,1);
        catch
            badMasks = [badMasks i];
        end
    end
    kymoStructs(badMasks) = []; % remove kymos with bad masks


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
    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');

    save(fullfile(outputTarget,['session_data',timestamp,'.mat']),'barcodeGen','barGenMerged','kymoStructs')

    if ~isKymo

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
    
    end
    
    if runMP % if we already want to pre-calculate MP stuff here. Might need some modifications depending on data

        sF = 0.95:0.01:1.05;
        minOverlap = 300;
    
        % bars = barGenMerged(length(posSingle):end);
        bars = barGenMerged(cellfun(@(x) sum(x.rawBitmask),barGenMerged)>300);
        [oS] = calc_overlap_mp(bars,sF, minOverlap,timestamp);
        
        save(fullfile(outputTarget,'mp_data.mat'),'minOverlap','oS','sF')
    end


end

