function [ sets,mol2 ] = choose_barcodes( )
   
    % default settings
    import CA.CombAuc.Import.set_default_settings;
    sets = set_default_settings();

    % add sequence plasmid path
    path = uigetdir(pwd,'Sequenced plasmids db');
    addpath(genpath(path));
    sets.kymoFold = strcat([path '/']);

    sets.stretchPar = 1.88;
    sets.alignMethod = 1; % 0 - nralign, 1 - ssdalign

    import CA.CombAuc.Import.generate_database_barcodes;    
    mol2 = generate_database_barcodes(sets);

    for i=1:length(mol2)

        % generate barcodes
        import CA.CombAuc.Import.gen_barcodes;
        mol2{i} = gen_barcodes(mol2{i},sets);

        % new consensus code
        sets.barcodeConsensusSettings.barcodeNormalization = 'bgmean';
        sets.barcodeConsensusSettings.barcodeClusterLimit = 0.75;

        import CA.CombAuc.Import.generate_consensus
        mol2{i}.consensusStruct = generate_consensus( mol2{i}, sets );

        import CA.CombAuc.Import.select_consensus
        mol2{i} = select_consensus( mol2{i}, sets );
    end


    % Extract molecule length (either from Lambda's, or from a given
    % theoretical sequence)

    % define molecule lengths from the database sequences (assuming they are
    % correct...)
    import CA.CombAuc.Import.generate_database_lengths;    
    mol2 = generate_database_lengths(sets,mol2);

    %meanBpExt_nm = zeros(1,length(mol2));

    for i=1:length(mol2)
        mol2{i}.meanBpExt_nm = sets.barcodeConsensusSettings.prestretchPixelWidth_nm*mean(mol2{i}.lengths)/length(mol2{i}.sequence);
    end


end

