classdef BindingMoleculeSample < handle
    % BINDINGMOLECULESAMPLE - Class to represent a sample of a molecule
    %  which can bind along DNA, occupying a fixed number of basepairs
    
    properties (SetAccess = protected)
        Name
        BindingConstantRules
        BindingConstantsMatrix
        RelativeQuantity
    end
    
    methods
        function [bms] = BindingMoleculeSample(moleculeName, bindingConstantRules, relativeQuantity)
            % BINDINGMOLECULESAMPLE - Constructor for Binding Molecule
            %  Sample object 
            %
            % Inputs:
            %   moleculeName
            %     the name of the molecule
            %   bindingConstantRules
            %     rules specifying how strongly the molecule binds to
            %     certain sequences of DNA nucleotides (mapping of
            %     nucleotide sequences occupied to equilibrium
            %     dissociation constants)
            %     Nx2 cell array with N >= 1 rules
            %     - where the first column represents specifications for
            %     nucleotide sequence characters with length k > 0 where
            %     all characters are valid IUPAC nucleotide codes and are
            %     not the code for a gap/unknown nucleotide label
            %     - where rhe second column represents the binding constant
            %     for the specified sequence as a positive, scalar, finite
            %     number
            %     - where higher-indexed rows take precedence over
            %     lower-indexed rows
            %   relativeQuantity
            %     the relative quantity of the sample is as a multiple of
            %     molar
            %
            % Outputs:
            %   bms
            %     the constructed Binding Molecule Sample object
            %
            % Authors:
            %   Saair Quaderi
            
            validateattributes(moleculeName, {'char'}, {'row'}, 1);
            
            [errMsg, isValid] = Barcoding.CB.BindingMoleculeSample.validate_binding_constant_rules(bindingConstantRules);
            if not(isValid)
                error(errMsg);
            end
            
            validateattributes(relativeQuantity, {'numeric'}, {'positive', 'scalar'}, 3);
            
            bindingConstantMatrix = Barcoding.CB.BindingMoleculeSample.decompress_binding_constants(bindingConstantRules);
            
            bms.Name = moleculeName;
            bms.BindingConstantRules = bindingConstantRules;
            bms.BindingConstantsMatrix = bindingConstantMatrix;
            bms.RelativeQuantity = relativeQuantity;
        end
    end
    
    methods (Static)
        function [errMsg, isValid] = validate_binding_constant_rules(bindingConstantRules)
            % VALIDATE_BINDING_CONSTANT_RULES - checks whether the binding
            %   constant rules are specified in a valid format
            %
            % Inputs:
            %   bindingConstantRules
            %     rules specifying how strongly the molecule binds to a
            %     certain sequence of DNA nucleotides (equilibrium
            %     dissociation constants mapped to nucleotide sequences)
            %     Valid if it is an Nx2 cell array with N >= 1 rules
            %     - where the first column represents specifications for
            %     nucleotide sequence characters with length k > 0 where
            %     all characters are valid IUPAC nucleotide codes and are
            %     not the code for a gap/unknown nucleotide label
            %     - where rhe second column represents the binding constant
            %     for the specified sequence as a positive, scalar, finite
            %     number
            %     - where higher-indexed rows take precedence over
            %     lower-indexed rows
            % 
            % Outputs:
            %   errMsg
            %     error message explaining why it is not valid if it is not
            %     valid (or empty otherwise)
            %   isValid
            %     true if the binding constant rules are specified in a
            %     valid format and false otherwise
            % 
            % Authors:
            %   Saair Quaderi
            
            errMsg = '';
            isValid = true;
            
            numRules = size(bindingConstantRules, 1);
            if numRules < 1
                errMsg = 'At least one rule must be specified';
                isValid = false;
            end
            if not(iscell(bindingConstantRules)) || not(isequal(size(bindingConstantRules), [numRules, 2]))
                errMsg = 'Rules must be specified in an Nx2 cell array';
                isValid = false;
            end
            seqSpecs = bindingConstantRules(:, 1);
            seqSpecLens = cellfun(@numel, seqSpecs);
            bpsOccupied = seqSpecLens(1);
            
            if bpsOccupied  < 1
                errMsg = 'Bound ligands must occupy at one nucleotide';
                isValid = false;
            end
            
            if any(seqSpecLens ~= bpsOccupied)
                errMsg = 'Varying sequence specification lengths are not supported';
                isValid = false;
            end
            
            if any(cellfun(@(seqSpec) not(ischar(seqSpec)) || feval(@(seqSpecInt) (seqSpecInt < 1) || (15 < seqSpecInt), nt2int(seqSpec)),  seqSpecs))
                errMsg = 'The first column must contain valid sequence specifications with only non-gap/non-unknown IUPAC nucleotide codes';
                isValid = false;
            end
            
            if any(cellfun(@(ntCharSeq) feval(@(bindingConst) not(isscalar(bindingConst)) || not(isnumeric(bindingConst)) || not(isreal(bindingConst)) || not(isfinite(bindingConst)) || (bindingConst < 0), bindingConstantRules.(ntCharSeq)), structFieldNames));
                errMsg = 'The second column must contain valid binding constants which are scalar, finite, real, positive numbers';
                isValid = false;
            end
        end
        
        function [bindingConstantsMat] = decompress_binding_constants(bindingConstantRules)
            % DECOMPRESS_BINDING_CONSTANTS - Expands out the binding constant rules
            %  specified to create a 4x4x...x4 matrix with k dimensions where k is
            %  the number of nucleotides in a bound sequence and the four
            %  indices (1, 2, 3, and 4) in the jth dimension are associated with
            %  an A, C, G, and T respectively in the jth character in the sequence
            %  to be bound to
            %
            % Inputs:
            %   bindingConstantRules
            %     rules specifying how strongly the molecule binds to a
            %     certain sequence of DNA nucleotides (equilibrium
            %     dissociation constants mapped to nucleotide sequences)
            %     Nx2 cell array with N >= 1 rules
            %     - where the first column represents specifications for
            %     nucleotide sequence characters with length k > 0 where
            %     all characters are valid IUPAC nucleotide codes and are
            %     not the code for a gap/unknown nucleotide label
            %     - where rhe second column represents the binding constant
            %     for the specified sequence as a positive, scalar, finite
            %     number
            %     - where higher-indexed rows take precedence over
            %     lower-indexed rows
            %
            % Outputs:
            %   bindingConstantsMat
            %     matrix specifying how strongly the molecule binds to a
            %     certain sequence of DNA nucleotides (equilibrium
            %     dissociation constants mapped to nucleotide sequences)
            %     4x4x...x4 matrix with k dimensions where k is the number of 
            %     nucleotides in a bound sequence and the four indices
            %     (1, 2, 3, and 4) in the jth dimension are associated with
            %     an A, C, G, and T respectively in the jth character in the
            %     sequence to be bound to
            %
            % Authors:
            %   Saair Quaderi

            import NtSeq.Core.get_bitsmart_ACGT;
            import NtSeq.Core.uint8_in_binary;

            numRules = size(bindingConstantRules, 1);
            seqSpecs = bindingConstantRules(:, 1);
            bindingConstantsMatSize = repmat(4, [1, seqSpecLen]);
            bindingConstantsMat = NaN(bindingConstantsMatSize);
            bindingConstantVals = [bindingConstantRules{:,2}]';
            for ruleNum=1:numRules
                mat_logical = uint8_in_binary(get_bitsmart_ACGT(seqSpecs{ruleNum}), 4);
                idxs = mat2cell(mat_logical, ones([1, size(mat_logical, 1)]), 4);
                bindingConstantsMat(idxs{:}) = bindingConstantVals(ruleNum);
            end
        end
    end
end

