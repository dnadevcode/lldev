classdef CB_TheoryBarcode < handle
    % CB_THEORYBARCODE - Competitive binding theory barcode
    
    properties
        DNASeqObj
        BindingCompetitors
        MicCamConfig
    end
    
    methods
        function [cbtb] = CB_TheoryBarcode(dnaSeqObj, bindingCompetitors, micCamConfig)
            cbtb.DNASeqObj = dnaSeqObj;
            cbtb.BindingCompetitors = bindingCompetitors;
            cbtb.MicCamConfig = micCamConfig;
        end
    end
    
    methods(Static)
        function [cbtb] = generate_theory_barcode(dnaSeqObj, bindingCompetitors, micCamConfig)
            if not(isempty(dnaSeqObj))
                validateattributes(dnaSeqObj, {'Barcoding.DNA_Seq'}, {'scalar'});
            end
            
            validateattributes(bindingCompetitors, {'Barcoding.CB.BindingMoleculeSample'}, {});
            
            validateattributes(micCamConfig, {'Barcoding.Microscopy.MicCamConfig'}, {});
                
            cbtb.DNASeqObj = dnaSeqObj;
            cbtb.BindingCompetitors = bindingCompetitors;
            cbtb.MicCamConfig = micCamConfig;
        end
        
    end
    
end
