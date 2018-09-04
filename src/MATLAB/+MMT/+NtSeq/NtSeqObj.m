classdef NtSeqObj < handle
    % NTSEQOBJ - DNA Sequence object
    
    properties (Constant, Access = private)
        Version = [0 0 1];
        
        DefaultSequence = '';
        DefaultHeader = '';
        DefaultImportItemContext = []
        DefaultImportSeqIdxInFile = NaN;
    end
    
    properties
        Sequence = NtSeq.NtSeqObj.DefaultSequence;
        Header = NtSeq.NtSeqObj.DefaultHeader;
        ImportItemContext = NtSeq.NtSeqObj.DefaultImportItemContext;
        ImportSeqIdxInFile = NtSeq.NtSeqObj.DefaultImportSeqIdxInFile;
    end
    
    methods
        function [ntSeqObj] = NtSeqObj(sequence, header, importItemContect, importSeqIdxInFile)
            ntSeqObj.Sequence = sequence;
            ntSeqObj.Header = header;
            ntSeqObj.ImportItemContext = importItemContect;
            ntSeqObj.ImportSeqIdxInFile = importSeqIdxInFile;
        end
    end
end