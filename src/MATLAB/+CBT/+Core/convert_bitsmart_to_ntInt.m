function [ntInt] = convert_bitsmart_to_ntInt(bitsmartData)
    % CONVERT_BITSMART_TO_NTINT - converts a uint8 sequence in our
    %   custom bitsmart encoding to a uint8 sequence corresponding to
    %   nucleotide integers in accordance with Matlab's variation of IUPAC
    %   nucleotide codes
    %
    % Inputs:
    %   bitsmartData
    %     uint8 values (specifically 32 or between 1-16) encoding
    %     DNA nucleotide labels (see CBT.Core.get_bitsmart_ACGT for details)
    %  
    %  Outputs:
    %    ntInt
    %      the integers Matlab encodes the nucleotide labels to
    %      (note that int2nt can be used to convert these into IUPAC
    %      nucleotide codes)
    %
    % Authors:
    %   Saair Quaderi
    
    import NtSeq.Core.get_bitsmart_ACGT;
    
    ntIntCodesIUPAC = uint8(0:16); % = nt2int('*ACGTRYKMSWBDHVN-');
    validateattributes(bitsmartData, {'uint8'}, {});
    bitsmartTransMat = get_bitsmart_ACGT(ntIntCodesIUPAC);
    moduloNum = numel(bitsmartTransMat) + 1;
    ntInt = arrayfun(@(x) mod(find([bitsmartTransMat, x] == x, 1), moduloNum) - 1, bitsmartData);
    if any(ntInt == - 1)
        error('Invalid bitsmart input sequence');
    end
    ntInt = uint8(ntInt);
end