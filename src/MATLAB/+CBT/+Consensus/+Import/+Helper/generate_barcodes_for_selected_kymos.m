function [kymoStructs] = generate_barcodes_for_selected_kymos(lm, skipConfirmation, skipSuccessMessage)
    if nargin < 2
        skipConfirmation = false;
    end
    if nargin < 3
        skipSuccessMessage = false;
    end
    selectedIndices = lm.get_selected_indices();
    numSelected = length(selectedIndices);
    kymoStructs = cell(numSelected, 1);
    if numSelected < 1
        questdlg('You must select some kymographs first!', 'Not Yet!', 'OK', 'OK');
        return;
    end

    if not(skipConfirmation)
        confirmContinuePrompt = sprintf('Generate barcodes for %d kymographs?', numSelected);
        confirmContinueChoice = questdlg(confirmContinuePrompt, 'Barcode Generation Confirmation', 'Continue','Abort', 'Continue');

        quitBarcodeGeneration = strcmp(confirmContinueChoice, 'Abort');
        if quitBarcodeGeneration
            fprintf('Barcode generation aborted\n');
            return;
        end
    end
    
  
    trueValueList = lm.get_true_value_list();
    import CBT.Consensus.Import.Helper.ensure_barcode_generated_at_index;
    
    detectEdges = 1;
    % check if we need to still detect edges
    for selectedIdx = 1:numSelected
        if not(isfield(trueValueList{selectedIdx}, 'barcodeGen'))
            % check if for some elements barcodes are not generated yet
            detectEdgesChoice = questdlg('Detect edges?', 'Barcode Edge Detection', 'Yes','No', 'Yes');
            detectEdges = strcmp(detectEdgesChoice, 'Yes');
            break;
        end        
    end
  
    
    for selectedIdx = 1:numSelected
        kymoIndex = selectedIndices(selectedIdx);
        [kymoStructs{selectedIdx},  trueValueList] = ensure_barcode_generated_at_index(kymoIndex, lm, trueValueList,detectEdges);
    end
    lm.update_list_items(lm.get_diplay_names(lm.get_all_indices), trueValueList);
    if not(skipSuccessMessage)
        fprintf('Barcode generations are complete!\n');
    end
end