  function [] = export_raw_kymos(dbmOSW,dbmStruct,timestamp)
%         if ~isfield(sets,'choose_output_folder')
%             sets.choose_output_folder = 1;
%         end
%         try
%             dbmOSW.DBMSettingsstruct = sets;
%         catch
%         end
        sets =  dbmOSW.DBMSettingsstruct ;

        if sets.choose_output_folder==1
            try
                [defaultOutputDirpath,~] = fileparts(dbmOSW.DBMSettingsstruct.movies.movieNames{1});
                outputDirpath = fullfile(defaultOutputDirpath,['raw_kymo_',timestamp]);
                [~,~] = mkdir(outputDirpath);
            catch
                defaultOutputDirpath = DBM4.UI.default_output_path('RawKymos');

%                 defaultOutputDirpath = dbmOSW.get_default_export_dirpath('raw_kymo');
                outputDirpath = uigetdir(defaultOutputDirpath, 'Select Directory to Save Raw Kymo Files');
            end
        else
            outputDirpath = sets.outputDirpath;
        end
        
                
        files = cellfun(@(rawKymo, outputKymoFilepath)...
        isfile(fullfile(outputDirpath,outputKymoFilepath)),...
        dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
        
        if sum(files) > 0
            cellfun(@(rawKymo, outputKymoFilepath)...
            delete(fullfile(outputDirpath,outputKymoFilepath)),...
            dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
        end

        % save 1) enhanced 2) kymo 3) enhanced
        if ~isfield(dbmStruct.kymoCells,'enhanced')
             dbmStruct.kymoCells.enhanced =  cellfun(@(rawKymo) imadjust(rawKymo/max(rawKymo(:)),[0.1 0.95]),dbmStruct.kymoCells.rawKymos,'un',false);
        end
         cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(round(double(rawKymo)./max(rawKymo(:))*2^16)), fullfile(outputDirpath,outputKymoFilepath), 'tif','WriteMode','append'),...
        dbmStruct.kymoCells.enhanced, dbmStruct.kymoCells.rawKymoName);

        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif','WriteMode','append'),...
        dbmStruct.kymoCells.rawKymos, dbmStruct.kymoCells.rawKymoName);
    
        cellfun(@(rawKymo, outputKymoFilepath)...
        imwrite(uint16(rawKymo), fullfile(outputDirpath,outputKymoFilepath), 'tif','WriteMode','append'),...
        dbmStruct.kymoCells.rawBitmask, dbmStruct.kymoCells.rawKymoName);

        disp(['Kymo data saved at ',defaultOutputDirpath ])

    end