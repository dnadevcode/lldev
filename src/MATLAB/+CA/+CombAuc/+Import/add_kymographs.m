function [ kymoStructs ] = add_kymographs(sets )

    % load kymos
    listing = dir(sets.kymoFold);

    numfild = length(listing);

    kymoStructs = struct();
    kymoStructs.unalignedKymos = cell(1,numfild-2);
    kymoStructs.names = cell(1,numfild-2);
    for K = 3:numfild
        tifName = listing(K).name;
        kymoStructs.unalignedKymos{K-2} = imread(tifName);
        kymoStructs.names{K-2} = tifName ;
    end


end

