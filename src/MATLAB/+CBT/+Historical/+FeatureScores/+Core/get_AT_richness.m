function [richnessAT] = get_AT_richness(ntSeq)
    % GET_AT_RICHNESS = Calculate how rich a sequence is in A & T basepairs
    %
    % Inputs:
    %   ntSeq
    %     DNA sequence
    %
    % Outputs:
    %   richnessAT
    %    double from 0 to 1 representing AT-richness
    %    the value is the portion of sequence
    %    known to be (A, T, or either A or T) over the portion of
    %    basepairs known to be either (A, T, or either A or T) OR
    %    alternatively (C, G, or either C or G) -- i.e. ignores
    %    basepairs that cannot be classified as AT (W) or CG (S)
    %
    % Authors:
    %   Saair Quaderi

    import NtSeq.Core.get_bitsmart_ACGT;
    ntBitsmartSeq = get_bitsmart_ACGT(ntSeq);

    ntsOfInterest = {'A'; 'C'; 'G'; 'T'; 'W'; 'S'};
    numNtsOfInterest = length(ntsOfInterest);
    for ntsOfInterestNum = 1:numNtsOfInterest
        ntOfInterest = ntsOfInterest{ntsOfInterestNum};
        ntBitsmart_uint8.(ntOfInterest) = get_bitsmart_ACGT(ntOfInterest);
    end
    countATW = sum(...
        (ntBitsmart_uint8.A == ntBitsmartSeq) +...
        (ntBitsmart_uint8.T == ntBitsmartSeq) +...
        (ntBitsmart_uint8.W == ntBitsmartSeq));
    countCGS = sum(...
        (ntBitsmart_uint8.C == ntBitsmartSeq) +...
        (ntBitsmart_uint8.G == ntBitsmartSeq) +...
        (ntBitsmart_uint8.S == ntBitsmartSeq));
    richnessAT = countATW / (countATW + countCGS);
end