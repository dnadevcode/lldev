function [ mol2 ] = generate_correctly_aligned_barcodes(sets)
    % generate_correctly_aligned_barcodes
    
    % input sets
    
    % output syntheticStruct

    sets.filterSettings.filterSize = 0;
    sets.defaultBarcodeGenSettings.concYOYO1_molar = 0.04; % important to have correct barcode gen settings
    sets.defaultBarcodeGenSettings.concDNA = 0.2;
    sets.barcodeConsensusSettings.barcodeNormalization = 'bgmean';

    % stretching factors
    sets.barcodeConsensusSettings.stretchFactors = [1];

    % then second step is to generate consensus barcodes.

    % then generate database barcodes
    import BC.Core.choose_barcodes;
    [sets,mol2] = choose_barcodes();

    titlesExp = {'Consensus PLOS005A','Consensus PLOS005B','Consensus PUUH'};
    %

    % then load theoretical sequences. Either from .mat or from .fasta
    titlesTheor = {'Theoretical PLOS005A','Theoretical PLOS005B','Theoretical PUUH'};

    dirName = uigetdir(pwd,'Plasmid folder');
    addpath(genpath(dirName));
    listing = dir(dirName);
    theory =struct();
    for i=3:length(listing)
        newPlasmid = fastaread(listing(i).name);
        theory.sequence{i-2} = newPlasmid.Sequence;
        theory.name{i-2} = newPlasmid.Header;
    end

    % now generate barcodes for these plasmids.
    lambdaSeq = uigetdir(pwd,'lambda sequence');
    addpath(genpath(lambdaSeq));
    listing = dir(lambdaSeq);
    lambdaSequence = fastaread(listing(3).name);
    lenSeq = length(lambdaSequence.Sequence);

    % first determine nm/bp length based on lambda
    lambdaDirName = uigetdir(pwd,'lambda folder');
    addpath(genpath(lambdaDirName));
    listing = dir(lambdaDirName);
    expLambda = cell(1,length(listing)-2);
    for i=3:length(listing)
        lambdaD = strcat([lambdaDirName '/' listing(i).name]);
        listingD = dir(lambdaD);
        for j=3:length(listingD)
            expLambda{i-2}.unalignedKymos{j-2} = imread(listingD(j).name);
            expLambda{i-2}.names{j-2} =listingD(j).name;
        end
    end

    for i=1:length(expLambda)
        import CA.CombAuc.Import.align_kymos;
        expLambda{i} = align_kymos(sets,expLambda{i});
    end

    sets.prestretchMethod = 0; % 0 - do not prestretch % 1 - prestretch to common length
    for i=1:length(expLambda)  
        % generate barcodes
        import CA.CombAuc.Import.gen_barcodes;
        expLambda{i} = gen_barcodes(expLambda{i},sets);
    end

    for i=1:length(expLambda)  
         expLambda{i}.lengthAverage = mean(expLambda{i}.lengths);
         expLambda{i}.lengthStd = std(expLambda{i}.lengths);
         expLambda{i}.bpPerPx =  lenSeq/expLambda{i}.lengthAverage;
         expLambda{i}.bpPerNm = expLambda{i}.bpPerPx/sets.barcodeConsensusSettings.prestretchPixelWidth_nm;
         expLambda{i}.nmPerBp = sets.barcodeConsensusSettings.prestretchPixelWidth_nm/expLambda{i}.bpPerPx;
    end

    import BC.Core.choose_model;
    model = choose_model('literature');

    NETROPSINconc = sets.defaultBarcodeGenSettings.concNetropsin_molar;
    YOYO1conc = sets.defaultBarcodeGenSettings.concYOYO1_molar;
    concDNA = sets.defaultBarcodeGenSettings.concDNA;
    F = 400;
    K =1;
    kk = 26;
    % first recompute free concentrations. Only needed once for a given
    % yoyo/netropsin/dna concentrations.
    [~, xNew,~ ] = titration_function_full(lambdaSequence.Sequence,kk*K, F,YOYO1conc,NETROPSINconc,concDNA,model );
    sets.defaultBarcodeGenSettings.concNetropsin_molar =xNew(2);
    sets.defaultBarcodeGenSettings.concYOYO1_molar = xNew(1);



    for i=1:length(theory.sequence)     
        % first compute the extention. Alternatively use lambdas..
        sets.meanBpExt_nm = mol2{i}.meanBpExt_nm; % from theory lengths
        import CA.CombAuc.Core.Cbt.compute_theory;
        [theory.theorySeq{i},theory.bitmask{i},theory.barcodeBpRes{i},theory.bitmaskBpRes{i}] = compute_theory(theory.sequence{i},sets,model);        
    end

    sets.barcodeConsensusSettings.stretchFactors = [0.97:0.01:1.03];

    for i=1:length(mol2)
        sets.meanBpExt_nm = mol2{i}.meanBpExt_nm;
        mol2{i}.theorySeq = theory.theorySeq{i};
        mol2{i}.bitmask = theory.bitmask{i};
        mol2{i}.barcodeBpRes = theory.barcodeBpRes{i};
        mol2{i}.bitmaskBpRes = theory.bitmaskBpRes{i};
        import CA.CombAuc.UI.compare_theory_to_exp;
        mol2{i} = compare_theory_to_exp(mol2{i},sets);
% 
%         import CA.CombAuc.UI.compare_theory_to_exp_least_squares;
%         mol2LeastSquares{i} = compare_theory_to_exp_least_squares(mol2{i},sets);
        figure
        [mol2{i}.correctAlignedBar,mol2{i}.correctAlignedBit] = CA.CombAuc.Export.save_correct_alignment(mol2{i}.comparisonStructure{end},mol2{i}.theorySeq,mol2{i}.bitmask );
    end
    
    % instead of plot put them on a vector..
%     Plot.plot_comparison_exp_vs_exp(mol2{3}.comparisonStructure{end},mol2{3}.theorySeq,mol2{3}.bitmask);
    % 
    % currentFolder = pwd;
    % name = strcat([currentFolder '/session' datetime '.mat']);


    % make sure that they are correct in synth structure. Once this is done
    % we can load these from a saved structure anytime. So important. But
    % changes whenever we change theory. This is only needed for the part
    % with synthetic stuff.
%     for i=1:length(mol2)
%          % check that this is correct when orientation is changed
%          expBarcode = circshift(mol2{i}.consensusStruct.barcode,[0,mol2{i}.comparisonStructure{end}.pos(1)-1]);
%          expBitmask = circshift(mol2{i}.consensusStruct.bitmask,[0,mol2{i}.comparisonStructure{end}.pos(1)-1]);
%          syntheticStruct.barcode{i} = expBarcode;
%          syntheticStruct.bitmask{i} = expBitmask;
%          syntheticStruct.theorySeq{i} = theory.theorySeq{i};
%          syntheticStruct.bitmask{i} =  theory.bitmask{i};
%          
%        figure,plot(theory.theorySeq{i}/mean(theory.theorySeq{i}))
%        hold on
%         plot(expBarcode/mean(expBarcode))
% 
%     end
    
%      
%     mol2LeastSquares{1}.comparisonStructure{end}
%     mol2LeastSquares{2}.comparisonStructure{end}
%     mol2LeastSquares{3}.comparisonStructure{end}
% 
% 
%     mol2{1}.comparisonStructure{end}
%     mol2{2}.comparisonStructure{end}
%     mol2{3}.comparisonStructure{end}
% 
%     orientation = cell2mat(cellfun(@(x) x.comparisonStructure{end}.or,mol2,'UniformOutput',0)');
%     maxcoef = cell2mat(cellfun(@(x) x.comparisonStructure{end}.maxcoef,mol2,'UniformOutput',0)');
%     pos =  cell2mat(cellfun(@(x) x.comparisonStructure{end}.pos,mol2,'UniformOutput',0)');
% 
%     titlesExp = {'Consensus pUUH','Consensus pEC005A','Consensus pEC005B'};
%     titlesTheor = {'Theoretical pUUH','Theoretical pEC005A','Theoretical pEC005B'};
% % 
% %     h=figure
% %     ix = [1,3];
%     for ind=1:2
%         subplot(2,1,ind)
%         ii=ix(ind);
%         legendN = {titlesTheor{ii},titlesExp{ii}};
% 
%         Plot.plot_comparison_exp_vs_exp(mol2{ii}.comparisonStructure{end},mol2{ii}.theorySeq,mol2{ii}.bitmask);
%         ylabel('Mean-normalized intensity','Interpreter','latex')
%         ax = gca;
% 
%         ticksx = 0:20:length(mol2{ii}.theorySeq);
%         ticks = ticksx*1000/expLambda{ii}.bpPerPx;
%         ax.XTick = [ticks];
%         ax.XTickLabel = [ticksx];
%         xlabel('Position (kbp)','Interpreter','latex')
%         legend(legendN,'Interpreter','latex','Location','se')
%         title([legendN{1},' vs ', legendN{2}], 'Interpreter','latex')
%         ylim([0.5 1.5])
%         xlim([0,length(mol2{1}.theorySeq)])         
%     end


end

