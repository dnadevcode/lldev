function [allValid, hasError, errors, convertedValues] = cb_simple_input_validator(rawInputValues, inputValidators, inputNames, inputFormatConverters)
    numInputs = length(rawInputValues);
    if (nargin < 2) || isempty(inputValidators)
        inputValidators = cell(numInputs, 1);
    end
    if (nargin < 3) || isempty(inputNames)
        inputNames = strcat({'Input #'}, arrayfun(@(x) num2str(x), [1:numInputs]', 'UniformOutput', false));
    end
    if (nargin < 4)  || isempty(inputFormatConverters)
        inputFormatConverters = cell(numInputs, 1);
    end
    
    errors = cell(numInputs, 1);
    hasError = false(numInputs, 1);
    convertedValues = cell(numInputs, 1);
    for inputNum=1:numInputs
        inputName = inputNames{inputNum};
        variableValidator = inputValidators{inputNum};
        if not(isa(variableValidator, 'function_handle'))
            variableValidator = @(x) true;
        end
        inputValue = rawInputValues{inputNum};
        inputFormatConverter = inputFormatConverters{inputNum};
        if not(isa(inputFormatConverter, 'function_handle'))
            inputFormatConverter = @(x) x;
        end
        try
            convertedValue = inputFormatConverter(inputValue);
            convertedValues{inputNum} = convertedValue;
        catch me
            hasError(inputNum) = true;
            errorMessage = ['Format conversion of ''', inputValue, ''', the value for ''', inputName, ''' threw an error:', me.message];
            errors{inputNum} = struct('message', errorMessage);
            continue;
        end
        [isValid, invalidReason] = variableValidator(convertedValue);
        if not(isValid)
            hasError(inputNum) = true;
            errorMessage = ['The value ''', inputValue, ''' for ''', inputName, ''' appears to be invalid'];
            if not(isempty(invalidReason))
                errorMessage = [errorMessage, ' because ', invalidReason];
            end
            errors{inputNum} = struct('message', errorMessage);
        end
    end
    allValid = not(any(hasError));
end