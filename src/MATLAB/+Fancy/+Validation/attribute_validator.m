function [isValid, reasonInvalid] = attribute_validator(value, attribute)
    % attribute_validator - validates a value with a single attribute
    %  the single attribute may be a compound attribute (e.g. "or")
    %  see comments in generate_validator for details
	import Fancy.Validation.attribute_validator;
	
    isScalarValue = isscalar(value);
    isValid = false;
    if ischar(attribute)
        attribute = {attribute};
    end
    attributeName = lower(attribute{1});
    if not(ischar(attributeName))
        error('Unrecognized validation attribute');
    end
    if (length(attribute) == 1)
        switch attributeName
            case '2d'
                if not(length(size(value) < 3))
                    reasonInvalid = 'it is not two-dimensional';
                    return;
                end
            case '3d'
                if not(length(size(value) < 4))
                    reasonInvalid = 'it is not three-dimensional';
                    return;
                end
            case 'column'
                if not(iscolumn(value))
                    reasonInvalid = 'it is not a column vector';
                    return;
                end
            case 'row'
                if not(isrow(value))
                    reasonInvalid = 'it is not a row vector';
                    return;
                end
            case 'scalar'
                if not(isScalarValue)
                    reasonInvalid = 'it is not scalar';
                    return;
                end
            case 'vector'
                if not(isvector(value))
                    reasonInvalid = 'it is not a vector';
                    return;
                end
            case 'square'
                sz = size(value);
                if not(length(sz < 3))
                    reasonInvalid = 'it is not two-dimensional';
                    return;
                end
                if not(sz(1) == sz(2))
                    reasonInvalid = 'it is not a square matrix';
                    return;
                end
            case 'diag'
                if not(isdiag(value))
                    reasonInvalid = 'it is not a diagonal matrix';
                    return;
                end
            case 'nonempty'
                if (numel(value) == 0)
                    reasonInvalid = 'it is empty';
                    return;
                end
            case 'nonsparse'
                if issparse(value)
                    reasonInvalid = 'it is sparse';
                    return;
                end

            case 'binary'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if not(all((value == 0) | (value == 1)))
                    if isScalarValue
                        reasonInvalid = 'it is not binary';
                    else
                        reasonInvalid = 'it contains a value which is not binary';
                    end
                    return;
                end
            case 'even'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if any(not(isfinite(value)))
                    if isScalarValue
                        reasonInvalid = 'it is not finite';
                    else
                        reasonInvalid = 'it contains a value which is not finite';
                    end
                    return;
                end
                if any(mod(value, 2) > 0)
                    if isScalarValue
                        reasonInvalid = 'it is not an even integer';
                    else
                        reasonInvalid = 'it contains a value which is not an even integer';
                    end
                    return;
                end
            case 'odd'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if any(not(isfinite(value)))
                    if isScalarValue
                        reasonInvalid = 'it is not finite';
                    else
                        reasonInvalid = 'it contains a value which is not finite';
                    end
                    return;
                end
                if any(mod(value, 2) ~= 1)
                    if isScalarValue
                        reasonInvalid = 'it is not an odd integer';
                    else
                        reasonInvalid = 'it contains a value which is not an odd integer';
                    end
                    return;
                end
            case 'integer'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if any(not(isfinite(value)))
                    if isScalarValue
                        reasonInvalid = 'it is not finite';
                    else
                        reasonInvalid = 'it contains a value which is not finite';
                    end
                    return;
                end
                if any(mod(value, 1) > 0)
                    if isScalarValue
                        reasonInvalid = 'it is not an integer';
                    else
                        reasonInvalid = 'it contains a value which is not an integer';
                    end
                    return;
                end
            case 'real'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(not(isreal(value)))
                    if isScalarValue
                        reasonInvalid = 'it is not real';
                    else
                        reasonInvalid = 'it contains a value which is not real';
                    end
                    return;
                end
            case 'finite'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(not(isfinite(value)))
                    if isScalarValue
                        reasonInvalid = 'it is not finite';
                    else
                        reasonInvalid = 'it contains a value which is not finite';
                    end
                    return;
                end
            case 'nonnan'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a value which is NaN';
                    end
                    return;
                end
            case 'nonnegative'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(value < 0)
                    if isScalarValue
                        reasonInvalid = 'it is negative';
                    else
                        reasonInvalid = 'it contains a value which is negative';
                    end
                    return;
                end
            case 'nonzero'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any((value ~= 0))
                    if isScalarValue
                        reasonInvalid = 'it is zero';
                    else
                        reasonInvalid = 'it contains a value which is zero';
                    end
                    return;
                end
            case 'positive'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if any(value <= 0)
                    if isScalarValue
                        reasonInvalid = 'it is not positive';
                    else
                        reasonInvalid = 'it contains a value which is not positive';
                    end
                    return;
                end
            case 'decreasing'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if isrow(value) && any(diff(value(:)) >= 0)
                    reasonInvalid = 'it does not decrease monotonically across its only row vector';
                    return;
                end
                if any(diff(value) >= 0)
                    reasonInvalid = 'it does not decrease monotonically in every column';
                    return;
                end
            case 'increasing'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if isrow(value) && any(diff(value(:)) >= 0)
                    reasonInvalid = 'it does not increase monotonically across its only row vector';
                    return;
                end
                if any(diff(value) <= 0)
                    reasonInvalid = 'it does not increase monotonically in every column';
                    return;
                end
            case 'nondecreasing'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if isrow(value) && any(diff(value(:)) < 0)
                    reasonInvalid = 'it decreases in its only row vector';
                    return;
                end
                if any(diff(value) < 0)
                    reasonInvalid = 'it has a column with a decreasing value';
                    return;
                end
            case 'nonincreasing'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(isnan(value))
                    if isScalarValue
                        reasonInvalid = 'it is NaN';
                    else
                        reasonInvalid = 'it contains a NaN';
                    end
                    return;
                end
                if isrow(value) && any(diff(value(:)) > 0)
                    reasonInvalid = 'it increases in its only row vector';
                    return;
                end
                if any(diff(value) > 0)
                    reasonInvalid = 'it has a column with an increasing value';
                    return;
                end
            case 'nonpositive'
                if not(isnumeric(value)) && not(islogical(value))
                    reasonInvalid = 'it is neither numeric nor logical';
                    return;
                end
                if any(value > 0)
                    if isScalarValue
                        reasonInvalid = 'it is positive';
                    else
                        reasonInvalid = 'it contains a value which is positive';
                    end
                    return;
                end
            case 'graphics'
                if any(not(isgraphics(value)))
                    if isScalarValue
                        reasonInvalid = 'it is not a valid graphics object';
                    else
                        reasonInvalid = 'it contains a value which is not a valid graphics object';
                    end
                    return;
                end
            otherwise
                error(['Unrecognized validation attribute: ''', attribute, '''']);
        end
    elseif (length(attribute) == 2)
        attributeFirstParam = attribute{2};
        switch attributeName
            case 'size'
                sz = attributeFirstParam;
                if not(isnumeric(sz)) || not(isvector(sz)) 
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
                sz = sz(:)';
                sznonnanbitmask = not(isnan(sz));
                sznonnans = sz(sznonnanbitmask);
                if not(isreal(sznonnans)) || not(isfinite(sznonnans)) || not(mod(sznonnans, 1) == 0) || length(sz) < 2
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
                szActual = size(value);
                if (length(szActual) ~= length(sz)) || not(isequal(szActual(sznonnanbitmask), sznonnans))
                    requiredSizeStr = strjoin(arrayfun(@(x) strrep(num2str(x),'NaN','?'), sz, 'UniformOutput', false),'x');
                    actualSizeStr = strjoin(arrayfun(@num2str, szActual, 'UniformOutput', false),'x');
                    reasonInvalid = ['it has a size of ', actualSizeStr, ' when it should have a size of ', requiredSizeStr];
                    return;
                end
            case 'numel'
                if not(isscalar(attributeFirstParam)) || not(isnumeric(attributeFirstParam)) || not(isreal(attributeFirstParam)) || not(isfinite(attributeFirstParam)) || (mod(attributeFirstParam, 1) ~= 0)
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
                if not(numel(value) == attributeFirstParam)
                    reasonInvalid = ['it has ', num2str(numel(value)), ' elements when it should have ', num2str(attributeFirstParam), ' elements'];
                    return;
                end
            case 'ncols'
                if not(isscalar(attributeFirstParam)) || not(isnumeric(attributeFirstParam)) || not(isreal(attributeFirstParam)) || not(isfinite(attributeFirstParam)) || (mod(attributeFirstParam, 1) ~= 0)
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
                if (size(value, 1) ~= attributeFirstParam)
                    reasonInvalid = ['it has ', num2str(size(value, 1)), ' columns when it should have ', num2str(attributeFirstParam), ' columns'];
                    return;
                end
            case 'nrows'
                if not(isscalar(attributeFirstParam)) || not(isnumeric(attributeFirstParam)) || not(isreal(attributeFirstParam)) || not(isfinite(attributeFirstParam)) || (mod(attributeFirstParam, 1) ~= 0)
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
                if (size(value, 2) ~= attributeFirstParam)
                    reasonInvalid = ['it has ', num2str(size(value, 2)), ' rows when it should have ', num2str(attributeFirstParam), ' rows'];
                    return;
                end
            case 'ndims'
                if not(isscalar(attributeFirstParam)) || not(isnumeric(attributeFirstParam)) || not(isreal(attributeFirstParam)) || not(isfinite(attributeFirstParam)) || not(mod(attributeFirstParam, 1) == 0) || (attributeFirstParam < 2)
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
                if length(size(value)) > attributeFirstParam
                    reasonInvalid = ['it has more than ', num2str(attributeFirstParam), '-dimensional'];
                    return;
                end
            case '>'
                if isscalar(attributeFirstParam) && (isnumeric(attributeFirstParam) || islogical(attributeFirstParam))
                    if not(isnumeric(value)) && not(islogical(value))
                        reasonInvalid = 'it is neither numeric nor logical';
                        return;
                    end
                    if any(isnan(value))
                        if isScalarValue
                            reasonInvalid = 'it is NaN';
                        else
                            reasonInvalid = 'it contains a NaN';
                        end
                        return;
                    end
                    if any(not(value > attributeFirstParam))
                        if isScalarValue
                            reasonInvalid = ['it is not greater than ', num2str(attributeFirstParam)];
                        else
                            reasonInvalid = ['it contains a value which is not greater than ', num2str(attributeFirstParam)];
                        end
                        return;
                    end
                else
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
            case '>='
                if isscalar(attributeFirstParam) && (isnumeric(attributeFirstParam) || islogical(attributeFirstParam))
                    if not(isnumeric(value)) && not(islogical(value))
                        reasonInvalid = 'it is neither numeric nor logical';
                        return;
                    end
                    if any(isnan(value))
                        if isScalarValue
                            reasonInvalid = 'it is NaN';
                        else
                            reasonInvalid = 'it contains a NaN';
                        end
                        return;
                    end
                    if not(value >= attributeFirstParam)
                        if isScalarValue
                            reasonInvalid = ['it is not greater than or equal to ', num2str(attributeFirstParam)];
                        else
                            reasonInvalid = ['it contains a value which is not greater than or equal to ', num2str(attributeFirstParam)];
                        end
                        return;
                    end
                else
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
            case '<'
                if isscalar(attributeFirstParam) && (isnumeric(attributeFirstParam) || islogical(attributeFirstParam))
                    if not(isnumeric(value)) && not(islogical(value))
                        reasonInvalid = 'it is neither numeric nor logical';
                        return;
                    end
                    if any(isnan(value))
                        if isScalarValue
                            reasonInvalid = 'it is NaN';
                        else
                            reasonInvalid = 'it contains a NaN';
                        end
                        return;
                    end
                    if not(value < attributeFirstParam)
                        if isScalarValue
                            reasonInvalid = ['it is not less than ', num2str(attributeFirstParam)];
                        else
                            reasonInvalid = ['it contains a value which is not less than ', num2str(attributeFirstParam)];
                        end
                        return;
                    end
                else
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
            case '<='
                if isscalar(attributeFirstParam) && (isnumeric(attributeFirstParam) || islogical(attributeFirstParam))
                    if not(isnumeric(value)) && not(islogical(value))
                        reasonInvalid = 'it is neither numeric nor logical';
                        return;
                    end
                    if any(isnan(value))
                        if isScalarValue
                            reasonInvalid = 'it is NaN';
                        else
                            reasonInvalid = 'it contains a NaN';
                        end
                        return;
                    end
                    if not(value <= attributeFirstParam)
                        if isScalarValue
                            reasonInvalid = ['it is not less than or equal to ', num2str(attributeFirstParam)];
                        else
                            reasonInvalid = ['it contains a value which is not less than or equal to ', num2str(attributeFirstParam)];
                        end
                        return;
                    end
                else
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end


            case '=='
                if isScalarValue && (isnumeric(attributeFirstParam) || islogical(attributeFirstParam))
                    if not(isequal(value, attributeFirstParam))
                        if isScalarValue
                            reasonInvalid = ['it is not equal to ', num2str(attributeFirstParam)];
                        else
                            reasonInvalid = 'it is not equal to the required value';
                        end
                        return;
                    end
                elseif ischar(attributeFirstParam)
                    if not(strcmp(value, attributeFirstParam))
                        if isempty(value) || isrow(value)
                            reasonInvalid = ['it is not equal to ''', attributeFirstParam, ''''];
                        else
                            reasonInvalid = 'it is not equal to the required value';
                        end
                        return;
                    end
                elseif not(isequal(value, attributeFirstParam))
                    reasonInvalid = 'it is not equal to the required value';
                    return;
                end
            case 'isa'
                if ischar(attributeFirstParam)
                    if not(isa(value, attributeFirstParam))
                        reasonInvalid = ['it does not belong to the class ''', attributeFirstParam, ''''];
                        return;
                    end
                else
                    error(['Bad validation attribute setting for: ''', attributeName, '''']);
                end
            otherwise
                error(['Unrecognized validation attribute: ''', attributeName, '''']);
        end
    elseif strcmp(attributeName, 'or')
        subAttributeSets = attribute(2:end);
        numSubAttributes = length(subAttributeSets);
        reasonsInvalid = cell(numSubAttributes, 1);
        oneSimpleAttributePerSet = true;
        for subAttributeSetNum=1:numSubAttributes
            subAttributeSet = subAttributeSets{subAttributeSetNum};
            if oneSimpleAttributePerSet && iscell(subAttributeSet) && ((iscell(subAttributeSet{1}) && strcmpi('or', subAttributeSet{1}{1})) || (length(subAttributeSet) > 1))
                oneSimpleAttributePerSet = false;
            end
            [isValid, reasonsInvalid{subAttributeSetNum}] = attributes_validator(value, subAttributeSet);
            if isValid
                reasonInvalid='';
                return;
            end
        end
        isValid = false;
        if oneSimpleAttributePerSet
            reasonInvalid = strjoin(unique(reasonsInvalid), ' and ');
        else
            reasonInvalid = 'it fails all the options in a complex validation rule involving OR logic';
        end
        return;
    else
        error('Unrecognized validation attribute');
    end

    isValid = true;
    reasonInvalid = '';
end