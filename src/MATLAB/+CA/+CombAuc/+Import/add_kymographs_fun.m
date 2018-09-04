function [ kymoStructs,kymoNames ] = add_kymographs_fun(sets )

    % load kymos
    listing = dir(sets.kymoFold);

    numfild = length(listing);

    kymoStructs = struct();
    kymoStructs.unalignedKymo = cell(1,numfild-2);
    kymoStructs.kymoNames = cell(1,numfild-2);
    for K = 3:numfild
        tifName = listing(K).name;
        kymoStructs.unalignedKymo{K-2} = imread(tifName);
        kymoStructs.kymoNames{K-2} = tifName ;
    end


end

