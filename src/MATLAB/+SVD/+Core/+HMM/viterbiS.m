function [asd] = viterbiS(prof, bc)

    if ~isfield(prof, 'Em') || ~isfield(prof, 'Tr')
        error('Input profile not proper');
    elseif sum(bc - floor(bc)) || sum(bc > 60) || sum (bc < 1)
        error('barcode must be discretised. Call Barcodes.discretise()');
    else
        asd = 0;
    end
end
