function [ mol2 ] = generate_database_lengths( sets,mol2 )

    % load kymos
    listing = dir(sets.kymoFold);

    numfild = length(listing);
    %mol=cell(1,numfild-2);
    for J = 3:numfild
        kymPath = strcat([sets.kymoFold listing(J).name]);
        listing2 = dir(kymPath);
        kymPath = strcat([kymPath  '/' listing2(4).name]);
        
        if isequal(kymPath(end-4:end),'fasta')
            seq = fastaread(kymPath);
            mol2{J-2}.sequence = seq.Sequence;
        else
            fileID = fopen(kymPath,'r');
            Header = fgetl(fileID);
            formatSpec = '%s';
            mol2{J-2}.sequence = fscanf(fileID,formatSpec);
            fclose(fileID);
        end
  
    end


end

