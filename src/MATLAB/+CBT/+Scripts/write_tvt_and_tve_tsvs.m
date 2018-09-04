function [] = write_tvt_and_tve_tsvs(tveStructs, expSuperdirpath, tvtDirpath)
    % fka write_the_tsvs
    
    if nargin < 1
        defaultDirpath = pwd();
        defaultTveStructsMatFilename = 'tvePointerStructs.mat';
        defaultTveStructsMatFilepath = fullfile(defaultDirpath, defaultTveStructsMatFilename);
        [tveStructsMatFilename, dirpath] = uigetfile({'*.mat'}, 'Theory Vs Exp Structs', defaultTveStructsMatFilepath);
        if isequal(dirpath, 0)
            return;
        end
        tveStructsMatFilepath = fullfile(dirpath, tveStructsMatFilename);
        tveStructs = feval(@(s) s.tvePointerStructs, load(tveStructsMatFilepath, 'tvePointerStructs'));
    end
    
    if nargin < 2
        defaultExpSuperdirpath = pwd();
        expSuperdirpath = uigetdir(defaultExpSuperdirpath, 'Exp Curves Dirpath');
        if isequal(expSuperdirpath, 0)
            return;
        end
    end
    
    if nargin < 3
        defaultTvtDirpath = pwd();
        tvtDirpath = uigetdir(defaultTvtDirpath, 'TvT Dirpath');
        if isequal(tvtDirpath, 0)
            return;
        end
    end
    
    numStructs = length(tveStructs);
    import CBT.Scripts.write_tvt_and_tve_tsv;
    for structNum = 1:numStructs
        tveStruct = tveStructs{structNum};
        filename = tveStruct.filename;
        myTheoryName = tveStruct.myTheoryName;
        isConsensus = tveStruct.isConsensus;
        tvtFilename = tveStruct.tvtFilename;
        
        tvtFilepath = fullfile(tvtDirpath, tvtFilename);
        if isConsensus
            expMatpath = fullfile(expSuperdirpath, 'Consensus', filename);
        else
            expMatpath = fullfile(expSuperdirpath, 'Individual', filename);
        end
        
        for mergeDupes = 0:1
            write_tvt_and_tve_tsv(tvtFilepath, expMatpath, isConsensus, myTheoryName, logical(mergeDupes));
        end
    end
end