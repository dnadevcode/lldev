classdef DNA_Seq < handle
    % DNA_SEQ - DNA Sequence object
    
    properties (Constant, Access = private)
        DefaultSequence = '';
        DefaultHeader = '';
        DefaultIsPlasmidTF = false;
    end
    
    properties
        Sequence = Barcoding.DNA_Seq.DefaultSequence;
        Header = Barcoding.DNA_Seq.DefaultHeader;
        IsPlasmidTF = Barcoding.DNA_Seq.DefaultIsPlasmidTF;
        
    end
    
    methods
        function [dnaSeqObj] = DNA_Seq(ntSeqStr, seqHeader, isPlasmidTF)
            % DNA_SEQ - Constructor for DNA Sequence object
            
            if nargin < 1
                ntSeqStr = Barcoding.DNA_Seq.DefaultSequence;
            else
                if not(isempty(ntSeqStr))
                    validateattributes(ntSeqStr, {'char'}, {'row'}, 1);
                end
            end
            
            if nargin < 2
                seqHeader = Barcoding.DNA_Seq.DefaultHeader;
            else
                if not(isempty(seqHeader))
                    validateattributes(seqHeader, {'char'}, {'row'}, 2);
                end
            end
            
            if nargin < 3
                isPlasmidTF = Barcoding.DNA_Seq.DefaultIsPlasmid;
            else
                validateattributes(isPlasmidTF, {'logical'}, {'scalar'}, 3);
            end
            
            dnaSeqObj.Sequence = ntSeqStr;
            dnaSeqObj.Header = seqHeader;
            dnaSeqObj.IsPlasmidTF = isPlasmidTF;
        end
    end
    
    methods (Static)
        function [dnaSeqObjArr] = import_fasta_files(fastaFilepaths, plasmidFastasTF)
            import Barcoding.DNA_Seq;
            if nargin < 1
                import NtSeq.Import.UI.try_prompt_nt_seq_filepaths;
                [~, fastaFilepaths] = try_prompt_nt_seq_filepaths([], true, false);
            end
            
            if nargin < 2
                plasmidFastasTF = false;
            end
            
            import NtSeq.Import.import_fasta_nt_seqs;
            [ntSeqs, seqFastaHeaders, seqFilepaths, seqIdxsInFile] = import_fasta_nt_seqs(fastaFilepaths);
            numSeqs = length(ntSeqs);
            if isscalar(plasmidFastasTF) && (numSeqs > 1)
                plasmidFastasTF = false(numSeqs, 1);
            end
            dnaSeqObjArr = arrayfun(...
                @(idx) ...
                    DNA_Seq(ntSeqs{idx}, seqFastaHeaders{idx}, plasmidFastasTF(idx)), ...
                    (1:numSeqs)', ...
                    'UniformOutput', false);
        end
    end
    
end
