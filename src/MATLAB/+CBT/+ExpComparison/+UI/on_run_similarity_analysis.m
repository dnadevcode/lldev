function [ cache ] = on_run_similarity_analysis(lm,ts,cache )
     if nargin < 3
        cache = containers.Map();
    end

    import Fancy.UI.FancyList.FancyListMgrBtnSet;
    flmbs3 = FancyListMgrBtnSet();
    flmbs3.NUM_BUTTON_COLS = 1;
    flmbs3.add_button(run_comparison(ts));

    lm.add_button_sets(flmbs3);
    
    function [btnGenerateConsensus] = run_comparison(ts)
        
        function on_run_comparison(lm, ts)
            
            % selected items
            [selectedItems, ~] = get_selected_list_items(lm);
            
            % put the selected items in a structure
            stretchedConsensusBitmasks = cell(1,size(selectedItems,1));
            stretchedConsensusBarcodes =  cell(1,size(selectedItems,1));
            consensusBarcodeNames =  cell(1,size(selectedItems,1));

            for it=1:size(selectedItems,1)   
                barStr = selectedItems{it,2};
                stretchedConsensusBitmasks{it} = barStr.stretchedConsensusBitmasks;
                stretchedConsensusBarcodes{it} = barStr.stretchedConsensusBarcodes;
                consensusBarcodeNames{it} =  selectedItems{it,1};
            end
            


            % load default ETE settings
            eteSettings = ete_default_settings();

            % Standartize barcodes to the same px/bp resolution. Todo: simplify the
            % standartization
            if eteSettings.forceStretchToSameBpsPerPixel == true
                import CBT.ExpComparison.UI.standardize_barcodes;
                [stretchedConsensusBarcodes, stretchedKbpsPerPixel] = standardize_barcodes(stretchedConsensusBarcodes, consensusBarcodeNames, eteSettings.forceStretchToSameBpsPerPixel);
                if isempty(stretchedConsensusBarcodes) || not(all(stretchedKbpsPerPixel == stretchedKbpsPerPixel(1)))
                    fprintf('Standardization failed\n');
                    return;
                end
                sets.stretchedKbpsPerPixel = stretchedKbpsPerPixel(1);

                % Standartize consensusBitmasks aswell
                for i=1:length(stretchedConsensusBarcodes)
                    v = linspace(1, length(stretchedConsensusBitmasks{i}), length(stretchedConsensusBarcodes{i}));
                    stretchedConsensusBitmasks{i} = stretchedConsensusBitmasks{i}(round(v));
                end 
            end

            if eteSettings.promptUserForStretchFactors == 1
                import CBT.ExpComparison.Import.prompt_stretch_factors;
                sets.stretchFactors = prompt_stretch_factors();
            end

            % Is plasmid circular. Todo: ask this for every plasmid, so that we
            % would allow circular/linear plasmids
            if eteSettings.promptForCircular == 1
                plasmidOption = questdlg('Are the barcodes circular?','Circular input','Yes','No','Yes');
                eteSettings.isCircular = strcmp(plasmidOption,'Yes');
            end

            if  eteSettings.promptUserForZeroModelType == 1
                zeromodelquestion = questdlg('Which ZM should we use','ZM choice','px resolution','bp resolution','bp resolution');
                eteSettings.zeroModelResolution = strcmp(zeromodelquestion,'px resolution');    
            end
            % --- Zero Model ---
            if  eteSettings.promptUserForZeroModel == 1
                if eteSettings.zeroModelResolution == 0
                    % select bp-resolution meanFFT
                    eteSettings.nullModelPath = uigetfile(pwd,'Select pre-computed null model at bp resolution');
                    addpath(genpath( eteSettings.nullModelPath));  
                    meanFFTest = load(eteSettings.nullModelPath);
                    eteSettings.meanZeroModelFftFreqMags = meanFFTest.meanFFTEst;         
                else
                    import CBT.UI.prompt_pregen_zero_model;
                    [aborted, eteSettings.meanZeroModelFftFreqMags, eteSettings.zeroModelKbpsPerPixel] = prompt_pregen_zero_model();
                    if aborted
                        fprintf('No valid zero-model was provided\n');
                        return;
                    end
                end
            end
            
            % ask for a fit model
            if  eteSettings.askForFitModel == 1
                fitmodel = questdlg('Which p-value model to use','P-value choice','gumbel','functional','functional');
                if isempty(fitmodel)
                    fitmodel = 'functional';
                end
                eteSettings.fitModel = fitmodel;
            end

            % run the main comparison
            import CBT.ExpComparison.UI.exp_vs_exp_bitmasked_ui;
            exp_vs_exp_bitmasked_ui(...
                ts, ...
                consensusBarcodeNames, ...
                stretchedConsensusBarcodes, ...
                stretchedConsensusBitmasks, ...
                eteSettings);
        end  
        
      import Fancy.UI.FancyList.FancyListMgrBtn;
        btnGenerateConsensus = FancyListMgrBtn(...
            'Run ETE comparison on selected (bitmasked) barcodes', ...
            @(~, ~, lm) on_run_comparison(lm, ts));
    end
end

