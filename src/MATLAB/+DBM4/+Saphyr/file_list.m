function [fullfiles] = file_list(mainFold)
    % extraction contains a few steps. In the first step individual fields
    % of view are processed.

    
% find all runs
    runs = dir(fullfile(mainFold,'Run*'));
    numRuns = length(runs);
    % num scans/ this for each run
    scans = arrayfun(@(x) dir(fullfile(mainFold,runs(x).name,'Scan*')),1:numRuns, 'un',false);
    numScans = cellfun(@(x) length(x), scans);
    numBanks = 4; % should always be 4 banks

    try
        if isequal(mainFold,'D:\Metagenomic run\')
            load('fullfiles2.mat')
        else
            load('fullfiles.mat')
        end
    catch
        fullfiles =[];
        for i=1:numRuns
            for j=1:numScans(i)
                for d=1:numBanks
                    run = num2str(i);
                    scan = num2str(j,'%02.f');
                    bank = num2str(d);
                    
                    start = strcat(['Run' run '/Scan' scan '/Bank' bank '/']);% '\ or /' depending on system..
                    for l=1:3
                        foldEnd = fullfile(start,strcat(['*CH' num2str(l) '_*C*.tif']));  
                        
                        files = dir(fullfile(mainFold,foldEnd));
                        fullfiles.run(i).scan(j).bank(d).ch{l} = arrayfun(@(x) fullfile(files(x).folder,files(x).name),1:length(files),'un',false);
                        foldEndBG= fullfile(start,strcat(['DarkFrame_CH' num2str(l) '*']));            
                        filesBG = dir(fullfile(mainFold,foldEndBG));

                        fullfiles.run(i).scan(j).bank(d).bg{l} = arrayfun(@(x) fullfile(filesBG(x).folder,filesBG(x).name),1:length(filesBG),'un',false);

                    end
                    fullfiles.run(i).scan(j).bank(d).bg(cellfun(@(x) isempty(x),fullfiles.run(i).scan(j).bank(d).bg)) = [];
                    fullfiles.run(i).scan(j).bank(d).ch(cellfun(@(x) isempty(x),fullfiles.run(i).scan(j).bank(d).ch)) = [];

                end
            end
        end
    save('fullfiles2','fullfiles');
    end
end

