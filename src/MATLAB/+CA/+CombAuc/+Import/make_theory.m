function [ mleculeStruct ] =make_theory(sets,mleculeStruct )
    seq = load(sets.theoryFilePath);
    % load kymos
%     listing = dir(sets.kymoFold);
% 
%     numfild = length(listing);
% 
%     kymoStructs = struct();
%     kymoStructs.unalignedKymos = cell(1,numfild-2);
%     kymoStructs.names = cell(1,numfild-2);
%     for K = 3:numfild
%         tifName = listing(K).name;
%         kymoStructs.unalignedKymos{K-2} = imread(tifName);
%         kymoStructs.names{K-2} = tifName ;
%     end


    import CA.CombAuc.Core.Cbt.compute_cat_theory_barcode;
    [mleculeStruct.theorySeq,mleculeStruct.bitmask] = compute_cat_theory_barcode(seq.plasmid,sets);
end

