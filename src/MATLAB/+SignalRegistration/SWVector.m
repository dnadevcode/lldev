classdef SWVector < SignalRegistration.SWArray
    % SWVector - Special Weighted Vector
    % wraps nonempty vector of numeric values where values are
    %   real & finite
    %   OR NaN (if corresponding weight is 0)
    % supports labeling values in the vector as periodic
    % supports a vector of weights corresponding to the values
    %  where weights are in [0, 1] range
    %
    % Authors:
    %  Saair Quaderi (SQ)
    % 2015-09-21:
    %  SQ - Initial Creation
    %     Created as Subclass of SWArray
    %     Added constructor
    %     Public functions added:
    %        getLength
    
    methods
        function swVect = SWVector(valuesVect, scaledWeightsVect, dimensionalPeriodicity)
            % SWVECTOR (constructor)
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
            %    default value: vector where all scaled weights are set to 1
            %
            %  dimensionalPeriodicity (optional)
            %    Significance of binary value:
            %      1: values represent cyclical/periodic/repeating data
            %      0: values represent acyclical/aperiodic/nonrepeating data
            %
            %    default value: 0
            
            validateattributes(valuesVect,...
                {'numeric', 'logical'},...
                {'nonempty', 'vector'},...
                1);
            
            if nargin < 2
                % default scalar value
                scaledWeightsVect = 1;
            elseif islogical(scaledWeightsVect)
                % convert logical weights to numbers 
                scaledWeightsVect = double(scaledWeightsVect);
            end
            
            if nargin < 3
                % default value
                dimensionalPeriodicity = false(1, length(size(valuesMat)));
            end
            if isscalar(dimensionalPeriodicity) && ((dimensionalPeriodicity == 1) || (dimensionalPeriodicity == 0))
                tmp = dimensionalPeriodicity;
                dimensionalPeriodicity = false(1, length(size(valuesVect)));
                dimensionalPeriodicity(size(valuesVect) > 1) = tmp;
            end
            
             % Call superclass constructor
            swVect@SignalRegistration.SWArray(valuesVect, scaledWeightsVect, dimensionalPeriodicity); 
        end
        
        function len = get_length(swVect)
            % GETLENGTH - Returns the length of the Values vector
            % (same as that for Weights)
           len = length(swVect.Values); 
        end
    end
end

