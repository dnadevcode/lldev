function [matFilepath] = export_infoscores_txt(infoscores,matDirpath) 
    % Exports two plots as txt

    timestamp = datestr(clock(), 'yyyy-mm-dd_HH_MM_SS');
    matFilename = strcat([timestamp '_' 'means.txt']);
    matFilename2 = strcat([timestamp '_' 'stdev.txt']);
    matFilename3 = strcat([timestamp '_' 'infoscore.txt']);



    if isequal(matDirpath, 0)
        return;
    end
    
	matFilepath = fullfile(matDirpath, matFilename);

    fileID = fopen(matFilepath,'w');        
    fprintf(fileID,'%6.3e\n',cellfun(@(x) x.mean, infoscores));
    fclose(fileID);

    matFilepath = fullfile(matDirpath, matFilename2);

    fileID = fopen(matFilepath,'w');        
    fprintf(fileID,'%6.3e\n',cellfun(@(x) x.std, infoscores));
    fclose(fileID);

    matFilepath = fullfile(matDirpath, matFilename3);

    fileID = fopen(matFilepath,'w');        
    fprintf(fileID,'%6.3e\n',cellfun(@(x) x.score, infoscores));
    fclose(fileID);


end
