function [ kymoStructs,kymoNames ] = add_kymographs_fun(sets)

    % load kymos
    listing = dir(sets.kymoFold);

    numfild = length(listing);

    kymoStructs = cell(1,numfild-2);
    kymoNames = cell(1,numfild-2);
    for K = 3:numfild
        tifName = listing(K).name;
        kymoStructs{K-2}.unalignedKymo = imread(tifName);
        kymoNames{K-2} = tifName ;
    end


end

