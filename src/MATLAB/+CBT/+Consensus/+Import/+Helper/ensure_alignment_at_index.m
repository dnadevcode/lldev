function [alignedKymo, kymoStruct, trueValueList] = ensure_alignment_at_index(kymoIndex, lm, trueValueList, dispSkippingMsg,alignmentChoiceNo)
    if nargin < 3
        trueValueList = lm.get_true_value_list();
    end
    if nargin < 4
        dispSkippingMsg = false;
    end

    if nargin < 5
        alignmentChoiceNo = 0;
    end

    kymoDispName = lm.get_diplay_names(kymoIndex);
    kymoDispName = kymoDispName{1};
    kymoStruct = trueValueList{kymoIndex};
    if not(isfield(kymoStruct, 'alignedKymo')) || isempty(kymoStruct.alignedKymo)
        unalignedKymo = kymoStruct.unalignedKymo;
        if alignmentChoiceNo~=1
            fprintf('Aligning ''%s''...\n', kymoDispName);
            import OptMap.KymoAlignment.NRAlign.nralign;
            [alignedKymo] = nralign(unalignedKymo);
        else
            fprintf('Skipping non-aligned ''%s''...\n', kymoDispName);
            alignedKymo = unalignedKymo;
        end
        kymoStruct.alignedKymo = alignedKymo;
    else
        alignedKymo = kymoStruct.alignedKymo;
        if dispSkippingMsg
            fprintf('Skipping pre-aligned ''%s''...\n', kymoDispName);
        end
    end
    trueValueList{kymoIndex} = kymoStruct;
end