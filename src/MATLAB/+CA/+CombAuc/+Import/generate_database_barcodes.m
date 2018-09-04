function [ mol ] = generate_database_barcodes( sets )

    % load kymos
    listing = dir(sets.kymoFold);

    numfild = length(listing);
    mol=cell(1,numfild-2);
    for J = 3:numfild
        kymPath = strcat([sets.kymoFold listing(J).name]);
        moleculeStruct.folderName = listing(J).name;
        listing2 = dir(kymPath);
        kymPath = strcat([kymPath  '/' listing2(5).name]);

        listing2 = dir(kymPath);
        numfild = length(listing2);

        kymoStructs = struct();
        kymoStructs.unalignedKymos = cell(1,numfild-2);
        kymoStructs.names = cell(1,numfild-2);
        for K = 3:numfild
            tifName = listing2(K).name;
            kymoStructs.unalignedKymos{K-2} = imread(tifName);
            kymoStructs.names{K-2} = tifName ;
        end
        moleculeStruct = struct();
        moleculeStruct.unalignedKymos = kymoStructs.unalignedKymos;
        moleculeStruct.names = kymoStructs.names;


        % align kymos
        % align kymos
        import CA.CombAuc.Import.align_kymos;
        moleculeStruct = align_kymos(sets,moleculeStruct);
%         
%         for i=1:length(mleculeStruct.alignedKymBitMask)
%             figure,imshow(mleculeStruct.unAlignedKymBitMask{i},[])
%         end
            % 
    %     % generate barcodes
    %     import CBT.Hca.UI.Helper.gen_barcodes;
    %     mleculeStruct = gen_barcodes(mleculeStruct,sets);
    % 
    %     
    %     import CBT.Hca.UI.Helper.gen_consensus
    %     mleculeStruct = gen_consensus(mleculeStruct,sets);
    % 
    %     import CA.CombAuc.Import.make_theory;
    %     [mleculeStruct] = make_theory(sets,mleculeStruct);
        mol{J-2} = moleculeStruct;
    end


end

