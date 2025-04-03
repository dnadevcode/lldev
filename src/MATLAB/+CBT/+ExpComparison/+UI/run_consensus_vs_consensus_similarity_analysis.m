function [] = run_consensus_vs_consensus_similarity_analysis(tsETE)
    % Takes several experiments and compares them to all other using the new
    % adam method with FFT for p-values.
    import OptMap.DataImport.prompt_and_read_consensus_outputs;
    fprintf('Started ETE many barcodes\n')

    %---User input---
    % Barcodes selection
    promptTitle = 'Select Consensus Files For Comparison';
    [consensusBarcodeNames, stretchedConsensusBarcodes,stretchedConsensusBitmasks, ~] = prompt_and_read_consensus_outputs(promptTitle);

    if isempty(stretchedConsensusBarcodes) % Stops the function if no barcodes were selected
        fprintf('No consensus data was provided\n');
        return;
    end

    
    % Length options
    forceStretchToSameBpsPerPixel = true;
    import CBT.ExpComparison.UI.standardize_barcodes;
    [stretchedConsensusBarcodes, stretchedKbpsPerPixel] = standardize_barcodes(stretchedConsensusBarcodes, consensusBarcodeNames, forceStretchToSameBpsPerPixel);
    if isempty(stretchedConsensusBarcodes) || not(all(stretchedKbpsPerPixel == stretchedKbpsPerPixel(1)))
        fprintf('Standardization failed\n');
        return;
    end
    



     %standartize consensusBitmasks aswell
       %standartize consensusBitmasks aswell
    % Bitmasks are not doing shit, lets crop barcodes (DO ONLY IF NEEDED
       n=6;
    for i=1:length(stretchedConsensusBarcodes)
    stretchedConsensusBarcodes{i}=stretchedConsensusBarcodes{i}((n+1):(end-n));
    end
    
    for i=1:length(stretchedConsensusBarcodes)
        v = linspace(1, length(stretchedConsensusBitmasks{i}), length(stretchedConsensusBarcodes{i}));
        stretchedConsensusBitmasks{i} = stretchedConsensusBitmasks{i}(round(v));
    end 


    
    
    stretchedKbpsPerPixel = stretchedKbpsPerPixel(1);
    stretchedBarcodeLens_pixels = cellfun(@length, stretchedConsensusBarcodes);
    sameLengthTF = all(stretchedBarcodeLens_pixels == stretchedBarcodeLens_pixels(1));
    % Stretching options]
    if sameLengthTF
        stretchFactors = [];
    else
        import CBT.ExpComparison.Import.prompt_stretch_factors;
        stretchFactors = prompt_stretch_factors();
    end

    % % Plasmid input
    % plasmidStr1 = 'Yes';
    % plasmidStr2 = 'No';
    % plasmidOption = questdlg('Are the barcodes circular?','Circular input',plasmidStr1,plasmidStr2,plasmidStr1);
    % isPlasmid = strcmp(plasmidStr1,plasmidOption);

    %---ZM ---
    % ZM preparations
    import CBT.UI.prompt_pregen_zero_model;
    [aborted, meanZeroModelFftFreqMags, zeroModelKbpsPerPixel] = prompt_pregen_zero_model();
    if aborted
        fprintf('No valid zero-model was provided\n');
        return;
    end


    import CBT.ExpComparison.UI.exp_vs_exp_ui;
    exp_vs_exp_ui(...
        tsETE, ...
        consensusBarcodeNames, ...
        stretchedConsensusBarcodes, ...
        stretchedConsensusBitmasks, ...
        stretchedKbpsPerPixel, ...
        stretchFactors, ...
        sameLengthTF, ...
        meanZeroModelFftFreqMags, ...
        zeroModelKbpsPerPixel ...
    );
    fprintf('Finished running consensus vs consensus similarity analyses\n');
end