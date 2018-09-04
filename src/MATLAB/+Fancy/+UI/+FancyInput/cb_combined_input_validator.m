function [allValid, hasError, errors] = cb_combined_input_validator(rawInputValues, convertedValues)
    numInputs = length(rawInputValues);
    hasError = false(numInputs, 1);
    errors = cell(numInputs, 1);
    allValid = true;
end