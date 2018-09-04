classdef WeightedBarcode < SignalRegistration.SWVector
    % WeightedBarcode - Weighted Circular/Linear Barcode
    % wraps nonempty barcode vector of numeric values where values are
    %   real & finite
    %   OR NaN (if corresponding weight is 0)
    % supports labeling values in the vector as cyclical
    % supports a vector of weights corresponding to the values
    %  where weights are in [0, 1] range
    % supports reordering of the barcode values and weight
    %   non-circular barcodes may be changed to a flipped version
    %   circular barcodes may be updated to a flipped &/or cyclical
    %      permutated version
    %
    % Authors:
    %  Saair Quaderi (SQ)
    
    properties (GetAccess = public, SetAccess = protected)
        IsCircular = false
        IsFlipped = false
        CircShiftAmount = 0
    end
    
    methods
        function [wBarcode] = WeightedBarcode(valuesVect, scaledWeightsVect, isCircular)
            % WEIGHTEDBARCODE (constructor)
            % inputs:
            %  valuesVect
            %    Vector of real, finite, nonnan numeric values
            %    Vector must be nonempty
            %
            %  scaledWeightsVect (optional)
            %    Vector of weights for values in valuesMat
            %    Scalar value can be provided for homogenous weighting 
            %    Otherwise this vector must have same dimension as valuesMat
            %    All scaled weights must be nonnan and in the range [0, 1]
            %    Logical values will be treated to numerical 0 or 1
            %
            %    default value: matrix where all scaled weights are set to 1
            %
            %  isCircular (optional)
            %    Significance of binary value:
            %      1: values represent cyclical/periodic/repeating data
            %      0: values represent acyclical/aperiodic/nonrepeating data
            %
            %    default value: 0

            if nargin < 2
                % default scalar value
                scaledWeightsVect = 1;
            end
            
            if nargin < 3
                % default value
                isCircular = false;
            end
            
            if isrow(valuesVect) && isrow(scaledWeightsVect)
                valuesVect = valuesVect(:);
                scaledWeightsVect = scaledWeightsVect(:);
            end
            
            % Call superclass constructor
            wBarcode@SignalRegistration.SWVector(...
                valuesVect, scaledWeightsVect, isCircular);
            wBarcode.IsCircular = isCircular;
        end
        
        function [wBarcode] = flip(wBarcode)
            % FLIP - Flip the barcode's current indexing
            
            % Toggle whether the barcode is to be flipped
            wBarcode.IsFlipped = ~wBarcode.IsFlipped;
            
            % Since the barcode's flip was toggled, any existing circshift
            %  should be applied in the opposite direction it was
            %  previously set to be in
            wBarcode.CircShiftAmount = mod(-wBarcode.CircShiftAmount, wBarcode.getLength());
        end
        
        function [wBarcode] = circshift(wBarcode, circShiftAmount)
            % CIRCSHIFT - Cyclically permutes the barcode
            % Inputs:
            %  circShiftAmount
            %    Integer scalar containing the number of positions to circshift
            %      the current indexing for the barcode
            
            validateattributes(circShiftAmount, {'numeric'}, {'scalar', 'integer'});
            if circShiftAmount ~= 0
                if not(wBarcode.IsCircular)
                    error('Cannot circshift a barcode unless it is circular');
                end
                wBarcode.CircShiftAmount = mod(wBarcode.CircShiftAmount + circShiftAmount, wBarcode.getLength());
            end
        end
        
        function [indicesVect] = get_indices(wBarcode)
            % GETINDICES - get current reordering indices
            %  returns the current reordered indexing of the barcode after
            %    calculates effects of any flipping/circular-shifting
            
            circShiftAmount = wBarcode.CircShiftAmount;
            isFlipped = wBarcode.IsFlipped;
            len = wBarcode.getLength();
            indicesVect = (1:len);
            if isFlipped
                indicesVect = fliplr(indicesVect);
            end
            indicesVect = circshift(indicesVect, circShiftAmount);
        end
        
        function [barcodeValuesVect] = get_barcode_values(wBarcode)
            % GETBARCODEVALUES - get current reordered barcode
            %  returns the barcode's values vector reordered by
            %    the current indices as determined by flip/circshift
            
            indices = wBarcode.get_indices();
            barcodeValuesVect = wBarcode.Values(indices);
        end

        function [barcodeWeightsVect] = get_barcode_weights(wBarcode)        
            % GETBARCODEWEIGHTS - get current reordered barcode weights
            %  returns the barcode's weights vector reordered by
            %    the current indices as determined by flip/circshift

            indices = wBarcode.get_indices();
            barcodeWeightsVect = wBarcode.Values(indices);
        end
    end
end

