classdef DNA_Molecule < handle
    % DNA_MOLECULE - DNA Sequence object
    
    properties
        DNASeqObj
    end
    
    methods
        function [dnaMolObj] = DNA_Molecule(dnaSeqObj)
            % DNA_MOLECULE - Constructor for DNA Molecule object
            
            if not(isempty(dnaSeqObj))
                validateattributes(dnaSeqObj, {'Barcoding.DNA_Molecule'}, {'scalar'});
            end
            
            dnaMolObj.DNASeqObj = dnaSeqObj;
        end
    end
    
end
