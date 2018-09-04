classdef SWArray < handle
    % SWArray - Special Weighted Array
    % wraps nonempty array of numeric values where values are
    %   real & finite
    %   OR NaN (if corresponding weight is 0)
    % supports labeling values in a dimension as periodic
    % supports an array of weights corresponding to the values
    %  where weights are in [0, 1] range
    %
    % Authors:
    %  Saair Quaderi (SQ)
    % 2015-09-21:
    %  SQ - Initial Creation
    %     Created as Subclass of handle
    %     Added constructor
    %     Get-public, Set-protected properties added:
    %        Values, ScaledWeights, DimensionalPeriodicities
    %     Public functions added:
    %        getSize, getPeriods, getScaledWeightedValues
    
    properties (GetAccess = public, SetAccess = protected)
        Values
        ScaledWeights
        DimensionalPeriodicities
    end
    
    methods
        function [swArr] = SWArray(valuesArr, scaledWeightsArr, dimensionalPeriodicitiesVect)
            % SWARRAY (constructor)
            % inputs:
            %  valuesArr
            %    Array of real, finite, nonnan numeric values
            %    Array must be nonempty
            %
            %  scaledWeightsArr (optional)
            %    Array of weights for values in valuesArr
            %    Scalar value can be provided for homogenous weighting 
            %    Otherwise this array must have same dimension as valuesMat
            %    All scaled weights must be nonnan and in the range [0, 1]
            %    Logical values will be treated to numerical 0 or 1
            %
            %    default value: array where all scaled weights are set to 1
            %
            %  dimensionalPeriodicitiesVect (optional)
            %    Vector of binary values
            %    Significance of kth value in the vector:
            %      1: values represent cyclical/periodic/repeating data
            %           in kth dimension
            %      0: values represent acyclical/aperiodic/nonrepeating data
            %           in kth dimension
            %
            %    default value: 0 for all dimensions
            
            if islogical(valuesArr)
                %convert logical values to numbers
                valuesArr = double(valuesArr);
            end
            
            if nargin < 2
                % default scalar value
                scaledWeightsArr = 1;
            elseif islogical(scaledWeightsArr)
                % convert logical weights to numbers 
                scaledWeightsArr = double(scaledWeightsArr);
            end
            
            if nargin < 3
                % default vector value
                dimensionalPeriodicitiesVect = false(1, length(size(valuesArr)));
            end
            
            % validate values array
            nonnanValuesArr = valuesArr;
            nonnanValuesArr(isnan(valuesArr)) = 0;
            validateattributes(nonnanValuesArr,...
                {'numeric'},...
                {'nonempty', 'real', 'finite'}, 1);
            
            % validate weights array
            validateattributes(scaledWeightsArr,...
                {'numeric'},...
                {'nonempty', 'nonnan', '>=', 0, '<=', 1},...
                2);
            if numel(scaledWeightsArr) == 1 % convert scalar into array
                scaledWeightsArr = zeros(size(valuesArr)) + scaledWeightsArr; % same size as values
            end
            
            % verify value and weight arrays have same dimensions
            if not(isequal(size(valuesArr), size(scaledWeightsArr)))
                error('The values array and weights array have mismatching dimension sizes');
            end
            
            if any(isnan(valuesArr(:)) & (scaledWeightsArr(:) > 0))
                error('All NaN values must have weights of 0');
            end
                
            % validate dimensional periodicity values
            validateattributes(dimensionalPeriodicitiesVect,...
                {'logical', 'numeric'},...
                {'binary', 'vector', 'numel', length(size(valuesArr))},...
                3);
            if not(islogical(dimensionalPeriodicitiesVect))
                %convert binary numeric values to logical
                dimensionalPeriodicitiesVect = logical(dimensionalPeriodicitiesVect);
            end
            if not(isrow(dimensionalPeriodicitiesVect))
                % orient vector as row vector
                dimensionalPeriodicitiesVect = dimensionalPeriodicitiesVect(:)';
            end
            
            % Set properties for class
            swArr.Values = valuesArr;
            swArr.ScaledWeights = scaledWeightsArr;
            swArr.DimensionalPeriodicities = dimensionalPeriodicitiesVect;
        end
        
        function [sz] = get_size(swArr)
            % GETSIZE - Returns the size of the array for Values
            % (same as that for Weights)
            
            sz = size(swArr.Values);
        end
        
        function [periods] = get_periods(swArr)
            % GETPERIODS - Returns the period lengths for each dimension
            %  e.g. size of the arrays for Values
            %   but with the values for dimensions which aren't periodic
            %   set to NaN
            
            periods = swArr.get_size();
            periods(~swArr.DimensionalPeriodicities) = NaN;
        end
        
        function [scaledWeightedValues] = get_scaled_weighted_values(swArr)
            % GETSCALEDWEIGHTEDVALUES - Returns the values scaled by the
            %  weights
            %  e.g. element-wise product of Values and Weights arrays
            %   but with values set to 0 wherever the weight is zero
            %   (even if NaN)
            
            scaledWeightedValues = swArr.Values.*swArr.ScaledWeights;
            scaledWeightedValues(swArr.ScaledWeights == 0) = 0;
        end
    end
end

