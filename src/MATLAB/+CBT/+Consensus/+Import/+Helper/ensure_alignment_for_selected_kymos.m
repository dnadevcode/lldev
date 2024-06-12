function [lm, kymoNames, alignedKymos] = ensure_alignment_for_selected_kymos(lm)
    % ensure_alignment_for_selected_kymos
    
    % input lm
    % output lm, kymoNames, alignedKymos
    
    % all indices
    allIndices = lm.get_all_indices();

    selectedIndices = lm.get_selected_indices();
    kymoNames = cell(0, 1);
    alignedKymos = cell(0, 1);

    lenKymos = length(selectedIndices);
    if lenKymos < 1
        questdlg('You must select some kymographs first!', 'Not Yet!', 'OK', 'OK');
        return;
    end

    confirmContinuePrompt = sprintf('Align %d kymographs?', lenKymos);
    confirmContinueChoice = questdlg(confirmContinuePrompt, 'Kymograph Alignment Confirmation', 'Continue','No','Abort', 'Continue');
    quitAlignment = strcmp(confirmContinueChoice, 'Abort');
    if quitAlignment
        fprintf('Kymograph alignments aborted\n');
        return;
    end
    alignmentChoiceNo =  strcmp(confirmContinueChoice, 'No');

    trueValueList = lm.get_true_value_list();
    import CBT.Consensus.Import.Helper.ensure_alignment_at_index;
    % should not be passing the whole truevalue list here!


    numSelected = length(selectedIndices);
    alignedKymos = cell(numSelected, 1);
    for selectedIdx = 1:numSelected
        kymoIndex = selectedIndices(selectedIdx);
        [~, kymoStruct, trueValueList] = ensure_alignment_at_index(kymoIndex, lm, trueValueList, true);
        alignedKymos{selectedIdx} = kymoStruct.alignedKymo;
    end
    % select the ones update for updating display
	kymoNames = lm.get_diplay_names(selectedIndices);
    % but update all items
	lm.update_list_items( lm.get_diplay_names(allIndices), trueValueList);
    fprintf('Kymograph alignments are complete!\n');
end